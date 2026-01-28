class CreateChartNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :chart_numbers do |t|
      t.references :chart, null: false, foreign_key: { on_delete: :cascade }
      t.references :numerology_number, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
