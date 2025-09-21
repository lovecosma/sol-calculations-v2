class CreateDescriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :descriptions do |t|
      t.text :long
      t.text :short
      t.string :context, null: false
      t.references :numerology_number, null: false, foreign_key: true
      t.timestamps
    end
  end
end
