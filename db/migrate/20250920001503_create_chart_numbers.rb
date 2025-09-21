class CreateChartNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :chart_numbers do |t|
      t.references :chart, null: false, foreign_key: true
      t.references :numerology_number, null: false, foreign_key: true
      t.timestamps
    end
  end
end
