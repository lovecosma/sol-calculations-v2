class AddCelebrityToCharts < ActiveRecord::Migration[8.0]
  def change
    add_reference :celebrities, :celebrity_chart, foreign_key: { to_table: :charts, on_delete: :nullify }
  end
end
