class MoveSubIdToUsersAssistants < ActiveRecord::Migration[5.0]
  def change
    execute("drop table if exists users_assistants_subscriptions")
    add_column :assistant_payment_requests, :subscription_plan_id, :integer, after: 'accepted_at'
    add_column :assistant_payment_requests, :stripe_subscription_id, :string, after: 'accepted_at'
  end
end
