class Invoice < ApplicationRecord
  belongs_to :user

  enum :status, {
    draft: "draft",
    sent: "sent",
    paid: "paid",
    overdue: "overdue"
  }

  validates :external_id, :amount_cents, :status, presence: true

  scope :this_month, -> { where(issued_at: Time.current.beginning_of_month..) }

  def amount_euros
    amount_cents / 100.0
  end
end
