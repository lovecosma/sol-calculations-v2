class CreateNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :numbers do |t|
      t.integer :value, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
  end
end
