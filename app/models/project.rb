class Project < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(status: "active") }
end
