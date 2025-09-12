class CreateCharts < ActiveRecord::Migration[8.0]
  def change
    create_table :charts do |t|
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name
      t.date :birth_date, null: false
      t.timestamps
    end
  end
end
