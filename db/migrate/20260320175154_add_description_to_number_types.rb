class AddDescriptionToNumberTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :number_types, :description, :text
    add_column :number_types, :thumbnail_description, :text
  end
end
