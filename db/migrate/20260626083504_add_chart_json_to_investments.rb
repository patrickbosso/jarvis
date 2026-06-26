class AddChartJsonToInvestments < ActiveRecord::Migration[8.1]
  def change
    add_column :investments, :chart_json, :jsonb
  end
end
