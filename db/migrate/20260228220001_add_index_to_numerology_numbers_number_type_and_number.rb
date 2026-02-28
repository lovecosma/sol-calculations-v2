class AddIndexToNumerologyNumbersNumberTypeAndNumber < ActiveRecord::Migration[8.0]
  def change
    add_index :numerology_numbers, [:number_type_id, :number_id]
  end
end
