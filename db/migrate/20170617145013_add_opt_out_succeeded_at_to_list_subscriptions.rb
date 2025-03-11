class AddOptOutSucceededAtToListSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :list_subscriptions, :opt_out_succeeded_at, :datetime, after: 'opt_out_at'
    add_column :list_subscriptions, :opt_out_failed_at, :datetime, after: 'opt_out_succeeded_at'
    add_column :list_subscriptions, :opt_out_failed_message, :string, after: 'opt_out_failed_at'
  end
end
