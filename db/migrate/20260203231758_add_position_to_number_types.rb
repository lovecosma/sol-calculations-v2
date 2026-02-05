class AddPositionToNumberTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :number_types, :position, :integer
  end
end
