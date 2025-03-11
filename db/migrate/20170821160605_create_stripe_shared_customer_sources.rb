class CreateStripeSharedCustomerSources < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_shared_customer_sources do |t|
      t.integer :stripe_shared_customer_id, null: false
      t.integer :deleted, limit: 1, default: 0, null: false
      t.string :card_id, null: false
      t.string :last4
      t.integer :exp_month, limit: 2
      t.integer :exp_year, limit: 4
      t.string :brand
      t.string :funding
      t.string :country
      t.timestamps
      t.index :stripe_shared_customer_id, name: 'idx_193'
    end
  end
end
