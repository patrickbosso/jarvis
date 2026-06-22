class TransferSuggestion < ApplicationRecord
  belongs_to :user

  enum :status, { pending: "pending", validated: "validated", dismissed: "dismissed" }
  enum :trigger, { client_payment: "client_payment", scheduled_daily: "scheduled_daily" }

  validates :suggested_at, :status, :trigger, presence: true

  def transfers
    transfers_json || []
  end
end
