class AddUserToCharts < ActiveRecord::Migration[8.0]
  def change
    add_reference :charts, :user, null: false, foreign_key: true
  end
end
