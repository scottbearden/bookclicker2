class AddCutoffDateToCalendar < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :cutoff_date, :date, after: 'click_rate'
  end
end
