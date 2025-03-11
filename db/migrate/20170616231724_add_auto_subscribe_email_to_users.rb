class AddAutoSubscribeEmailToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :auto_subscribe_email, :string, after: 'auto_subscribe_on_booking'
  end
end
