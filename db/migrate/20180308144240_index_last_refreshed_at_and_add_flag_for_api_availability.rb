class IndexLastRefreshedAtAndAddFlagForApiAvailability < ActiveRecord::Migration[5.0]
  def change
    add_index :lists, :last_refreshed_at
  end
end
