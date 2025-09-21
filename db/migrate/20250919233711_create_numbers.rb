class CreateNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :numbers do |t|
      t.integer :value, null: false
      t.timestamps
    end
  end
end
