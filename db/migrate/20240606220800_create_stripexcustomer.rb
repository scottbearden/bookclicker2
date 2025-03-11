class CreateStripexcustomer < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_customers)

    create_table :stripe_customers, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.integer :destination_stripe_account_id
      t.string :default_source
      t.string :cus_id, null: false
      t.string :currency
      t.string :email
      t.integer :deleted, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
