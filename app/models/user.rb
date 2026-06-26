class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :accounts
  has_many :invoices
  has_one :budget_rule
  has_many :projects
  has_many :transactions
  has_many :transfer_suggestions
  has_many :investments
end
