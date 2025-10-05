class CreateNumerologyNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :numerology_numbers do |t|
      t.references :number, null: false
      t.references :number_type, null: false
      t.text :description
      t.string :primary_title
      t.string :secondary_titles, array: true, default: []
      t.text :core_essence, array: true, default: []
      t.text :strengths, array: true, default: []
      t.text :challenges, array: true, default: []
      t.text :matches, array: true, default: []
      t.text :mismatches, array: true, default: []
      t.timestamps
    end
  end
end
