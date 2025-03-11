class AddAutoSubscribeOptionToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :auto_subscribe_on_booking, :integer, limit: 1, after: 'email_verified_at', null: false, default: 0
  end
end
