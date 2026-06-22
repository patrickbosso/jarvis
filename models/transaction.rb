class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account

  enum :direction, { credit: "credit", debit: "debit" }
  enum :category, {
    client_payment: "client_payment",
    salary: "salary",
    freelance: "freelance",
    expense: "expense",
    mortgage: "mortgage",
    savings: "savings"
  }

  validates :external_id, uniqueness: true, allow_nil: true
  validates :amount_cents, :direction, :occurred_at, presence: true

  scope :credits, -> { where(direction: "credit") }
  scope :debits, -> { where(direction: "debit") }
  scope :this_month, -> { where(occurred_at: Time.current.beginning_of_month..) }
end
