class AddOptInTimestampsToListSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :list_subscriptions, :opt_in_at, :datetime, after: 'email'
    add_column :list_subscriptions, :opt_in_succeeded_at, :datetime, after: 'opt_in_at'
    add_column :list_subscriptions, :opt_in_failed_at, :datetime, after: 'opt_in_succeeded_at'
    add_column :list_subscriptions, :opt_in_failed_message, :string, after: 'opt_in_failed_at'
  end
end
