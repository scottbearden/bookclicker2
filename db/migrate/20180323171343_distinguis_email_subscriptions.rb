class DistinguisEmailSubscriptions < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :email_subscribed, :bookings_subscribed
    add_column :users, :confirmations_subscribed, :integer, limit: 1, default: 1, null: false, after: "bookings_subscribed"
  end
end
