class CreateInvestments < ActiveRecord::Migration[8.1]
  def change
    create_table :investments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :isin
      t.string :yahoo_ticker
      t.decimal :shares
      t.integer :avg_price_cents
      t.integer :last_price_cents
      t.integer :prev_close_cents
      t.datetime :last_fetched_at

      t.timestamps
    end
  end
end
