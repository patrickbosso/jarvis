# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_26_083504) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "balance_cents"
    t.datetime "created_at", null: false
    t.string "currency"
    t.datetime "fetched_at"
    t.string "source"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "budget_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "freelance_budget_cents"
    t.integer "living_expenses_cents"
    t.integer "mortgage_amount_cents"
    t.integer "salary_target_cents"
    t.integer "savings_target_cents"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_budget_rules_on_user_id"
  end

  create_table "investments", force: :cascade do |t|
    t.integer "avg_price_cents"
    t.jsonb "chart_json"
    t.datetime "created_at", null: false
    t.string "isin"
    t.datetime "last_fetched_at"
    t.integer "last_price_cents"
    t.string "name"
    t.integer "prev_close_cents"
    t.decimal "shares"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "yahoo_ticker"
    t.index ["user_id"], name: "index_investments_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "amount_cents"
    t.string "client_name"
    t.datetime "created_at", null: false
    t.date "due_date"
    t.string "external_id"
    t.datetime "issued_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "client_name"
    t.datetime "created_at", null: false
    t.string "current_step"
    t.string "notion_id"
    t.string "status"
    t.datetime "synced_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "amount_cents"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "direction"
    t.string "external_id"
    t.string "label"
    t.datetime "occurred_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "transfer_suggestions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status"
    t.datetime "suggested_at"
    t.jsonb "transfers_json"
    t.string "trigger"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_transfer_suggestions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "budget_rules", "users"
  add_foreign_key "investments", "users"
  add_foreign_key "invoices", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "users"
  add_foreign_key "transfer_suggestions", "users"
end
