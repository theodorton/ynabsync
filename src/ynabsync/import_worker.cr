require "sidekiq"
require "../sbanken/client"

module Ynabsync
  class ImportWorker
    include Sidekiq::Worker

    def perform
      log = Logger.new(STDOUT)
      client = SBanken::Client.new
      transactions = client.list_transactions.items

      request_body = JSON.build do |json|
        json.object do
          json.field "transactions" do
            json.array do
              transactions.each do |transaction|
                json.object do
                  amount = (transaction.amount * 1000).to_i
                  json.field "account_id", ENV["YNAB_ACCOUNT_ID"]
                  json.field "date", transaction.interestDate
                  json.field "amount", amount
                  json.field "memo", transaction.text
                  json.field "cleared", transaction.accountingDate ? "cleared" : "uncleared"
                  json.field "approved", true
                  json.field "import_id", "YNAB:V3:#{amount}:#{transaction.interestDate.to_s("%F")}:1"
                end
              end
            end
          end
        end
      end

      log.info "Request body: #{request_body}"

      headers = HTTP::Headers{
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
      response = HTTP::Client.post "https://api.youneedabudget.com/v1/budgets/#{ENV["YNAB_BUDGET_ID"]}/transactions/bulk?access_token=#{ENV["YNAB_ACCESS_TOKEN"]}", headers, request_body
      puts response.body

      # NOTE: Duplicate import id's is impossible to reset (even by rejecting or deleting transactions)
    end
  end
end
