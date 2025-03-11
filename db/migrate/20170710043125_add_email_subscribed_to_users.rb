class AddEmailSubscribedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_subscribed, :integer, limit: 1, after: 'email_verified_at', default: 1, null: false
  end
end
