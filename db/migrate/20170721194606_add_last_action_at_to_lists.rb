class AddLastActionAtToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :last_action_at, :datetime, after: 'last_refreshed_at'
    add_index :lists, [:status, :last_action_at]
    execute("update lists set last_action_at = created_at")
  end
end
