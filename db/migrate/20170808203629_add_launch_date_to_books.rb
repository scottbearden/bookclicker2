class AddLaunchDateToBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :launch_date, :date, after: 'price'
  end
end
