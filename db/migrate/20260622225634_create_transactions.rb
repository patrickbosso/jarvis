class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :external_id
      t.integer :amount_cents
      t.string :direction
      t.string :label
      t.string :category
      t.datetime :occurred_at

      t.timestamps
    end
  end
end
