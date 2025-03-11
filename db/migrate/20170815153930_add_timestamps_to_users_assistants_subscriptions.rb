class AddTimestampsToUsersAssistantsSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :users_assistants_subscriptions, :created_at, :datetime
    add_column :users_assistants_subscriptions, :updated_at, :datetime
  end
end
