class CreateStripeSharedCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_shared_customers do |t|
      t.integer :user_id, null: false
      t.string :customer_id, null: false
      t.integer :deleted, limit: 1, default: 0, null: false
      t.string :email_address
      t.timestamps
      t.index [:user_id,:deleted], name: 'idx_shared_stripe'
      t.index :customer_id
    end
  end
end
