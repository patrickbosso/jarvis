class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notion_id
      t.string :title
      t.string :client_name
      t.string :status
      t.string :current_step
      t.datetime :synced_at

      t.timestamps
    end
  end
end
