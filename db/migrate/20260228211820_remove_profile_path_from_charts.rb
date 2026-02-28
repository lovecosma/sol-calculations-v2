class RemoveProfilePathFromCharts < ActiveRecord::Migration[8.0]
  def change
    remove_column :charts, :profile_path, :string
  end
end
