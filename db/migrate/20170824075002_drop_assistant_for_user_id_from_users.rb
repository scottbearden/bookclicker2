class DropAssistantForUserIdFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :assistant_for_user_id
  end
end
