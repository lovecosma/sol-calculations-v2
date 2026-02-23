class AddStiTypeToCharts < ActiveRecord::Migration[8.0]
  def up
    add_column :charts, :type, :string
    add_index :charts, :type
    change_column_null :charts, :user_id, true
    execute "UPDATE charts SET type = 'UserChart'"
  end

  def down
    execute "DELETE FROM charts WHERE type != 'UserChart'"
    change_column_null :charts, :user_id, false
    remove_index :charts, :type
    remove_column :charts, :type
  end
end
