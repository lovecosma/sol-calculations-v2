class CreateChartsNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :charts_numbers do |t|
      t.references :chart, null: false, foreign_key: true
      t.references :number, null: false, foreign_key: true
      t.timestamps
    end
  end
end
