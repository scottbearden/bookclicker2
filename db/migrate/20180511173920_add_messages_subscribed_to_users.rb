class AddMessagesSubscribedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :messages_subscribed, :integer, limit: 1, default: 1, after: "bookings_subscribed"
  end
end
