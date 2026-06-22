class TinkService
  AUTH_URL = "https://api.tink.com/api/1/oauth/token"
  BASE_URL = "https://api.tink.com/api/1"

  def initialize(user_access_token: nil)
    @user_access_token = user_access_token
  end

  def client_access_token
    response = Faraday.post(AUTH_URL, {
      client_id: ENV.fetch("TINK_CLIENT_ID"),
      client_secret: ENV.fetch("TINK_CLIENT_SECRET"),
      grant_type: "client_credentials",
      scope: "accounts:read,balances:read,transactions:read"
    })
    data = JSON.parse(response.body)
    data["access_token"]
  end

  def fetch_accounts
    conn = build_conn(@user_access_token)
    response = conn.get("accounts/list")
    data = JSON.parse(response.body)
    data["accounts"] || []
  end

  def fetch_balance(account_id)
    conn = build_conn(@user_access_token)
    response = conn.get("accounts/#{account_id}/balances")
    data = JSON.parse(response.body)
    data.dig("balance", "amount", "value", "unscaledValue").to_i
  end

  def sync_for_user(user)
    return unless @user_access_token

    accounts = fetch_accounts
    accounts.each do |acc|
      source = detect_source(acc)
      next unless source

      account = user.accounts.find_or_initialize_by(source: source)
      balance = fetch_balance(acc["id"])

      account.assign_attributes(
        balance_cents: balance,
        currency: acc.dig("currencyCode") || "EUR",
        fetched_at: Time.current
      )
      account.save!
    end
  end

  private

  def build_conn(token)
    Faraday.new(BASE_URL) do |f|
      f.request :retry, max: 2
      f.headers["Authorization"] = "Bearer #{token}"
      f.headers["Content-Type"] = "application/json"
    end
  end

  def detect_source(account)
    name = account["name"].to_s.downcase
    financial_institution = account.dig("financialInstitutionId").to_s.downcase

    return "sg_perso" if name.include?("société générale") || name.include?("sg") || financial_institution.include?("societe")
    return "trade_republic_pea" if name.include?("trade republic") || financial_institution.include?("trade_republic")
    nil
  end
end
