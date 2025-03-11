class AddAssistantIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :assistant_for_user_id, :integer, after: 'role'
    add_index :users, :assistant_for_user_id
  end
end
