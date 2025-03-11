class CreateStripexsharedxcustomerxsource < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_shared_customer_sources)

    create_table :stripe_shared_customer_sources, id: :serial, primary_key: :id do |t|
      t.integer :stripe_shared_customer_id, null: false
      t.integer :deleted, null: false
      t.integer :default
      t.string :card_id, null: false
      t.string :last4
      t.string :cvc_check
      t.integer :exp_month
      t.integer :exp_year
      t.string :brand
      t.string :funding
      t.string :country
      t.string :name
      t.string :address_line1
      t.string :address_line2
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.string :address_zip_check
      t.string :address_country
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
