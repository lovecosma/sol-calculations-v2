class AddPopularityIndexToCelebrities < ActiveRecord::Migration[8.0]
  def change
    add_index :celebrities, :popularity
  end
end
