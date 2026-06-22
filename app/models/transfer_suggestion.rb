class TransferSuggestion < ApplicationRecord
  belongs_to :user

  scope :pending, -> { where(status: "pending") }

  def transfers
    JSON.parse(transfers_json.presence || "[]")
  end
end
