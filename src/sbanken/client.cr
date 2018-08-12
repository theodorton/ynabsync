require "json"
require "http/client"

module SBanken
  class Token
    JSON.mapping(
      access_token: String,
      expires_in: Int32,
      token_type: String
    )
  end

  class Account
    JSON.mapping(
      account_id: {key: "accountId", type: String},
      account_number: {key: "accountNumber", type: String},
      available: {key: "available", type: Float32},
      balance: {key: "balance", type: Float32},
    )
  end

  class CardDetails
    JSON.mapping(
      card_number: {key: "cardNumber", type: String},
      currency_amount: {key: "currencyAmount", type: Float32},
      currency_rate: {key: "currencyRate", type: Float32},
      merchant_category_code: {key: "merchantCategoryCode", type: String},
      merchant_category_description: {key: "merchantCategoryDescription", type: String},
      merchant_city: {key: "merchantCity", type: String},
      merchant_name: {key: "merchantName", type: String},
      original_currency_code: {key: "originalCurrencyCode", type: String},
      purchase_date: {key: "purchaseDate", type: Time},
      transaction_id: {key: "transactionId", type: String},
    )
  end

  # See  https://github.com/Sbanken/api-examples#swagger-documentation
  enum TransactionSource
    AccountStatement
    Archive
  end

  enum ReservationType
    Null
    Visa
    Purchase
    Atm
  end

  class Transaction
    JSON.mapping(
      accounting_date: {key: "accountingDate", type: Time},
      interest_date: {key: "interestDate", type: Time},
      amount: {key: "amount", type: Float32},
      text: {key: "text", type: String},
      transaction_type: {key: "transactionType", type: String},
      transaction_type_code: {key: "transactionTypeCode", type: Int32},
      transaction_type_text: {key: "transactionTypeText", type: String},
      is_reservation: {key: "isReservation", type: Bool},
      reservation_type: {key: "reservationType", type: ReservationType?},
      source: {key: "source", type: TransactionSource},
      card_details: {key: "cardDetails", type: CardDetails?},
      card_details_specified: {key: "cardDetailsSpecified", type: Bool},
    )
  end

  class TokenErrorResponse
    JSON.mapping(
      error: {key: "error", type: String}
    )
  end

  class SuccessResponse(T)
    JSON.mapping(
      available_items: {key: "availableItems", type: Int32},
      items: {key: "items", type: Array(T)},
      is_error: {key: "isError", type: Bool},
      error_type: {key: "errorType", type: String?},
      error_message: {key: "errorMessage", type: String?},
      trace_id: {key: "traceId", type: String?}
    )
  end

  TokenResponse        = Union(Token, TokenErrorResponse)
  AccountsResponse     = SuccessResponse(Account)
  TransactionsResponse = SuccessResponse(Transaction)

  class Client
    getter token : Token?

    def initialize
      app_id = URI.escape ENV["SBANKEN_APP_ID"]
      secret = URI.escape ENV["SBANKEN_SECRET"]
      @auth = Base64.strict_encode("#{app_id}:#{secret}")
      @client = HTTP::Client.new "api.sbanken.no", tls: true
    end

    def connect : String
      if _token = @token
        return _token.access_token
      end
      headers = HTTP::Headers{
        "Authorization" => "Basic #{@auth}",
        "Accept"        => "application/json",
        "Content-Type"  => "application/x-www-form-urlencoded",
      }
      path = "/identityserver/connect/token"
      body = "grant_type=client_credentials"
      response = @client.post path, headers, body
      token = SBanken::TokenResponse.from_json(response.body)
      case token
      when Token
        @token = token.as(Token)
        return token.as(Token).access_token
      else
        raise token.error
      end
    end

    def list_accounts
      response = get "/Bank/api/v1/Accounts"
      AccountsResponse.from_json(response.body)
    end

    def list_transactions
      response = get "/Bank/api/v1/Transactions/#{ENV["ACCOUNT_ID"]}?index=0&length=1000"
      puts response.body
      TransactionsResponse.from_json(response.body)
    end

    private def get(path)
      access_token = connect
      headers = HTTP::Headers{
        "Authorization" => "Bearer #{access_token}",
        "Accept"        => "application/json",
        "customerId"    => ENV["CUSTOMER_ID"],
      }
      @client.get path, headers
    end
  end
end
