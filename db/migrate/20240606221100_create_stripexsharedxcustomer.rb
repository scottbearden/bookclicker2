class CreateStripexsharedxcustomer < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_shared_customers)

    create_table :stripe_shared_customers, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.string :customer_id, null: false
      t.integer :deleted, null: false
      t.string :email_address
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
