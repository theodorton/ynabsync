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
      accountId: String,
      accountNumber: String,
      available: Float32,
      balance: Float32,
    )
  end

  class CardDetails
    JSON.mapping(
      cardNumber: String,
      currencyAmount: Float32,
      currencyRate: Float32,
      merchantCategoryCode: String,
      merchantCategoryDescription: String,
      merchantCity: String,
      merchantName: String,
      originalCurrencyCode: String,
      purchaseDate: Time,
      transactionId: String
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
      accountingDate: Time,
      interestDate: Time,
      amount: Float32,
      text: String,
      transactionType: String,
      transactionTypeCode: Int32,
      transactionTypeText: String,
      isReservation: Bool,
      reservationType: ReservationType?,
      source: TransactionSource,
      cardDetails: CardDetails?,
      cardDetailsSpecified: Bool,
    )
  end

  class TokenErrorResponse
    JSON.mapping(
      error: String
    )
  end

  class SuccessResponse(T)
    JSON.mapping(
      availableItems: Int32,
      items: Array(T),
      isError: Bool,
      errorType: String?,
      errorMessage: String?,
      traceId: String?
    )
  end

  TokenResponse = Union(Token, TokenErrorResponse)
  AccountsResponse = SuccessResponse(Account)
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
