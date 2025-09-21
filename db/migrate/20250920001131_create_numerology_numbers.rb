class CreateNumerologyNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :numerology_numbers do |t|
      t.references :number, null: false
      t.references :number_type, null: false
      t.timestamps
    end
  end
end
