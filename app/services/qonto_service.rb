class QontoService
  BASE_URL = "https://thirdparty.qonto.com/v2"

  def initialize
    @conn = Faraday.new(BASE_URL) do |f|
      f.request :retry, max: 2
      f.response :raise_error
      f.headers["Authorization"] = "#{ENV.fetch('QONTO_ORGANIZATION_SLUG')}:#{ENV.fetch('QONTO_API_KEY')}"
      f.headers["Content-Type"] = "application/json"
    end
  end

  def fetch_balance
    response = @conn.get("organization")
    data = JSON.parse(response.body)
    bank_account = data.dig("organization", "bank_accounts")&.first
    return nil unless bank_account

    bank_account["balance_cents"]
  end

  def fetch_transactions(iban: nil, updated_at_from: nil)
    params = { current_page: 1, per_page: 100 }
    params[:iban] = iban if iban
    params[:updated_at_from] = updated_at_from.iso8601 if updated_at_from

    response = @conn.get("transactions", params)
    data = JSON.parse(response.body)
    data["transactions"] || []
  end

  def sync_for_user(user)
    account = user.accounts.find_or_initialize_by(source: "qonto_sas")

    balance = fetch_balance
    if balance
      account.balance_cents = balance
      account.fetched_at = Time.current
      account.save!
    end

    transactions = fetch_transactions(updated_at_from: 30.days.ago)
    transactions.each do |t|
      next if user.transactions.exists?(external_id: t["transaction_id"])

      user.transactions.create!(
        account: account,
        external_id: t["transaction_id"],
        amount_cents: t["amount_cents"].abs,
        direction: t["side"] == "credit" ? "credit" : "debit",
        label: t["label"],
        category: detect_category(t),
        occurred_at: Time.parse(t["settled_at"] || t["emitted_at"])
      )
    end
  end

  private

  def detect_category(transaction)
    label = transaction["label"].to_s.downcase
    return "client_payment" if transaction["side"] == "credit"
    return "salary" if label.include?("salaire") || label.include?("remuneration")
    return "freelance" if label.include?("freelance")
    return "mortgage" if label.include?("credit") || label.include?("prêt")
    return "savings" if label.include?("epargne") || label.include?("livret")
    "expense"
  end
end
