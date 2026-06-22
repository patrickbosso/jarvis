class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :budget_rule, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :transfer_suggestions, dependent: :destroy

  def qonto_account
    accounts.find_by(source: "qonto_sas")
  end
end
