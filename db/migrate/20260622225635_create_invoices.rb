class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id
      t.string :client_name
      t.integer :amount_cents
      t.string :status
      t.date :due_date
      t.datetime :issued_at

      t.timestamps
    end
  end
end
