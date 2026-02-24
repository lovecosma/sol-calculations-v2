class AddProfilePathToCharts < ActiveRecord::Migration[8.0]
  def change
    add_column :charts, :profile_path, :string
  end
end
