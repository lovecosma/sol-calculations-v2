class CreateCelebrities < ActiveRecord::Migration[8.0]
  def change
    create_table :celebrities do |t|
      t.integer :external_id, null: false
      t.string :original_name, null: false
      t.date :birthdate
      t.string :profile_path
      t.float :popularity

      t.timestamps
    end

    add_index :celebrities, :external_id, unique: true
  end
end
