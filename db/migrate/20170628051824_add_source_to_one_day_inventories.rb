class AddSourceToOneDayInventories < ActiveRecord::Migration[5.0]
  def change
    add_column :one_day_inventories, :source, :string, after: 'list_id', default: 'automatic', null: false
  end
end
