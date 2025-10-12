class AddThumbnailDescriptionToNumerologyNumbers < ActiveRecord::Migration[8.0]
  def change
    add_column :numerology_numbers, :thumbnail_description, :text
  end
end
