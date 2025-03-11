class AddSubscriptionStuffToUsersAssistants < ActiveRecord::Migration[5.0]
  def change
    create_table :assistant_payment_requests do |t|
      t.integer :users_assistant_id, null: false
      t.integer :pay_amount, null: false
      t.integer :pay_day, limit: 2
      t.datetime :response_at
      t.integer :response, limit: 1
      t.timestamps
      t.index [:users_assistant_id, :response_at], name: 'idx_on_whatever'
    end
  end
end
