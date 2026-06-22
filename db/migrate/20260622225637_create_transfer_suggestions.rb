class CreateTransferSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :transfer_suggestions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :suggested_at
      t.string :status
      t.jsonb :transfers_json
      t.string :trigger

      t.timestamps
    end
  end
end
