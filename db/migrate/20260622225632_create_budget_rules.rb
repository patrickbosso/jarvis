class CreateBudgetRules < ActiveRecord::Migration[8.1]
  def change
    create_table :budget_rules do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :salary_target_cents
      t.integer :mortgage_amount_cents
      t.integer :living_expenses_cents
      t.integer :savings_target_cents
      t.integer :freelance_budget_cents

      t.timestamps
    end
  end
end
