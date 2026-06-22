class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :source
      t.integer :balance_cents
      t.string :currency
      t.datetime :fetched_at

      t.timestamps
    end
  end
end
