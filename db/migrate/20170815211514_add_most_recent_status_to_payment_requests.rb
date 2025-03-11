class AddMostRecentStatusToPaymentRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :assistant_payment_requests, :last_known_subscription_status, :string
    add_column :assistant_payment_requests, :last_known_subscription_status_at, :datetime
  end
end
