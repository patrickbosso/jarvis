class BudgetRule < ApplicationRecord
  belongs_to :user

  validates :salary_target_cents, :mortgage_amount_cents, :living_expenses_cents,
            :savings_target_cents, :freelance_budget_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def fixed_charges_cents
    mortgage_amount_cents + freelance_budget_cents + living_expenses_cents
  end
end
