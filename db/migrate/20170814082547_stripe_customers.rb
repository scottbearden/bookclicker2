class StripeCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_customers do |t|
      t.integer :user_id, null: false
      t.string :cus_id, null: false
      t.string :currency
      t.string :email
      t.integer :deleted, limit: 1, default: 0, null: false
      t.timestamps
    end
  end
end
