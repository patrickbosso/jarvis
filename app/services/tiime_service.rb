class TiimeService
  BASE_URL = "https://app.tiime.fr/api"

  def initialize
    @conn = Faraday.new(BASE_URL) do |f|
      f.request :retry, max: 2
      f.response :raise_error
      f.headers["X-Api-Key"] = ENV.fetch("TIIME_API_KEY")
      f.headers["Content-Type"] = "application/json"
    end
  end

  def fetch_invoices
    response = @conn.get("invoices", { per_page: 100 })
    data = JSON.parse(response.body)
    data["invoices"] || data || []
  end

  def sync_for_user(user)
    invoices = fetch_invoices
    invoices.each do |inv|
      record = user.invoices.find_or_initialize_by(external_id: inv["id"].to_s)
      record.assign_attributes(
        client_name: inv.dig("client", "name") || inv["client_name"],
        amount_cents: (inv["total_including_taxes_amount"].to_f * 100).to_i,
        status: map_status(inv["status"]),
        due_date: inv["due_date"] ? Date.parse(inv["due_date"]) : nil,
        issued_at: inv["issued_at"] ? Time.parse(inv["issued_at"]) : nil
      )
      record.save!
    end
  end

  private

  def map_status(status)
    case status.to_s.downcase
    when "paid", "payée", "paye" then "paid"
    when "overdue", "en retard" then "overdue"
    when "draft", "brouillon" then "draft"
    else "sent"
    end
  end
end
