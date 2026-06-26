# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.find_or_create_by!(email: "admin@admin.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

# Accounts
Account.find_or_create_by!(user: user, source: "qonto_sas") do |a|
  a.balance_cents = 1_842_300
  a.currency = "EUR"
  a.fetched_at = 2.hours.ago
end

Account.find_or_create_by!(user: user, source: "sg_perso") do |a|
  a.balance_cents = 3_210_50
  a.currency = "EUR"
  a.fetched_at = 1.day.ago
end

Account.find_or_create_by!(user: user, source: "trade_republic_pea") do |a|
  a.balance_cents = 12_480_00
  a.currency = "EUR"
  a.fetched_at = 3.hours.ago
end

# Invoices — historical paid (Jan–May 2026)
[
  { client: "Collectif Nord",   amount: 3_200_00, ext: "INV-2026-001", month: 1 },
  { client: "Bureau Éclat",     amount: 5_500_00, ext: "INV-2026-002", month: 1 },
  { client: "Agence Lumière",   amount: 4_200_00, ext: "INV-2026-007", month: 2 },
  { client: "Maison Cléa",      amount: 2_800_00, ext: "INV-2026-008", month: 2 },
  { client: "Studio Moka",      amount: 6_000_00, ext: "INV-2026-015", month: 3 },
  { client: "Fondation Artes",  amount: 1_900_00, ext: "INV-2026-016", month: 3 },
  { client: "Collectif Nord",   amount: 4_500_00, ext: "INV-2026-023", month: 4 },
  { client: "Agence Lumière",   amount: 3_100_00, ext: "INV-2026-024", month: 4 },
  { client: "Bureau Éclat",     amount: 2_400_00, ext: "INV-2026-031", month: 5 },
  { client: "Maison Cléa",      amount: 5_800_00, ext: "INV-2026-032", month: 5 }
].each do |inv|
  Invoice.find_or_create_by!(user: user, external_id: inv[:ext]) do |i|
    i.client_name = inv[:client]
    i.amount_cents = inv[:amount]
    i.status = "paid"
    i.issued_at = Date.new(2026, inv[:month], 15)
    i.due_date = Date.new(2026, inv[:month], 15) + 30
  end
end

# Invoices — paid this month
[
  { client: "Agence Lumière", amount: 4_800_00, ext: "INV-2026-041" },
  { client: "Studio Moka", amount: 2_200_00, ext: "INV-2026-042" },
  { client: "Fondation Artes", amount: 1_500_00, ext: "INV-2026-043" }
].each do |inv|
  Invoice.find_or_create_by!(user: user, external_id: inv[:ext]) do |i|
    i.client_name = inv[:client]
    i.amount_cents = inv[:amount]
    i.status = "paid"
    i.issued_at = rand(1..20).days.ago
    i.due_date = 15.days.from_now
  end
end

# Invoices — sent (prévisionnel)
[
  { client: "Maison Cléa", amount: 3_600_00, ext: "INV-2026-044", due: 10.days.from_now },
  { client: "Collectif Nord", amount: 2_900_00, ext: "INV-2026-045", due: 18.days.from_now }
].each do |inv|
  Invoice.find_or_create_by!(user: user, external_id: inv[:ext]) do |i|
    i.client_name = inv[:client]
    i.amount_cents = inv[:amount]
    i.status = "sent"
    i.issued_at = 5.days.ago
    i.due_date = inv[:due]
  end
end

# Invoices — overdue
Invoice.find_or_create_by!(user: user, external_id: "INV-2026-038") do |i|
  i.client_name = "Bureau Éclat"
  i.amount_cents = 1_800_00
  i.status = "overdue"
  i.issued_at = 45.days.ago
  i.due_date = 15.days.ago
end

# Projects
[
  { title: "Identité visuelle", client: "Maison Cléa",    step: "Livrables V2",     notion: "notion-001" },
  { title: "Campagne print",    client: "Agence Lumière", step: "Validation client", notion: "notion-002" },
  { title: "Site vitrine",      client: "Studio Moka",    step: "Intégration",       notion: "notion-003" }
].each do |p|
  Project.find_or_create_by!(user: user, notion_id: p[:notion]) do |proj|
    proj.title = p[:title]
    proj.client_name = p[:client]
    proj.status = "active"
    proj.current_step = p[:step]
    proj.synced_at = 1.hour.ago
  end
end

# Budget rule
BudgetRule.find_or_create_by!(user: user) do |b|
  b.salary_target_cents    = 4_500_00
  b.mortgage_amount_cents  = 1_240_00
  b.living_expenses_cents  = 1_800_00
  b.savings_target_cents   = 600_00
  b.freelance_budget_cents = 860_00
end

# Investments — PEA ETFs (update shares + avg_price to reflect real position)
[
  {
    name:         "Amundi PEA Nasdaq-100 UCITS ETF Acc",
    isin:         "FR0011871128",
    yahoo_ticker: "PUST.PA",
    shares:       0,
    avg_price_cents: 0
  },
  {
    name:         "iShares MSCI World Swap PEA UCITS ETF EUR (Acc)",
    isin:         "IE000Y7KKL60",
    yahoo_ticker: "WPEA.PA",
    shares:       0,
    avg_price_cents: 0
  }
].each do |inv|
  Investment.find_or_initialize_by(user: user, isin: inv[:isin]).update!(
    name:            inv[:name],
    yahoo_ticker:    inv[:yahoo_ticker],
    shares:          inv[:shares],
    avg_price_cents: inv[:avg_price_cents]
  )
end

# Transfer suggestion — reset to pending on every seed so the demo card reappears
TransferSuggestion.find_or_initialize_by(user: user, trigger: "monthly_review").update!(
  status: "pending",
  suggested_at: Time.current,
  transfers_json: [
    { label: "Virement épargne",      amount_cents: 600_00 },
    { label: "Provision charges URSSAF", amount_cents: 430_00 },
    { label: "Remboursement crédit",  amount_cents: 1_240_00 }
  ].to_json
)
