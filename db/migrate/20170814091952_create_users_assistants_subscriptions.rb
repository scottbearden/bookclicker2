class CreateUsersAssistantsSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :users_assistants_subscriptions do |t|
      t.integer :users_assistant_id
      t.string :sub_id, null: false
      t.integer :subscription_plan_id, null: false
      t.datetime :ended_at
      t.index [:users_assistant_id, :ended_at], name: 'idx_wi'
    end
  end
end
