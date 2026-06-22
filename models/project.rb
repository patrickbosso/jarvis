class Project < ApplicationRecord
  belongs_to :user

  enum :status, {
    in_progress: "in_progress",
    feedback: "feedback",
    delivered: "delivered",
    archived: "archived"
  }

  validates :notion_id, :title, :status, presence: true

  scope :active, -> { where(status: %w[in_progress feedback]) }
end
