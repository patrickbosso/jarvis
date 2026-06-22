class Invoice < ApplicationRecord
  belongs_to :user

  scope :paid,       -> { where(status: "paid") }
  scope :sent,       -> { where(status: "sent") }
  scope :overdue,    -> { where(status: "overdue") }
  scope :this_month, -> { where(issued_at: Time.current.beginning_of_month..Time.current.end_of_month) }
end
