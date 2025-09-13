class CreateCharts < ActiveRecord::Migration[8.0]
  def change
    create_table :charts do |t|
      t.string :full_name, null: false
      t.date :birthdate, null: false
      t.timestamps
    end
  end
end
