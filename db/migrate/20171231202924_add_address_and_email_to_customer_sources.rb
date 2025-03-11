class AddAddressAndEmailToCustomerSources < ActiveRecord::Migration[5.0]
  def change
    rename_column :stripe_shared_customer_sources, :country, :address_country
    
    add_column :stripe_shared_customer_sources, :name, :string, after: :funding
    add_column :stripe_shared_customer_sources, :address_line1, :string, after: :name
    add_column :stripe_shared_customer_sources, :address_line2, :string, after: :address_line1
    add_column :stripe_shared_customer_sources, :address_city, :string, after: :address_line2
    add_column :stripe_shared_customer_sources, :address_state, :string, after: :address_city
    add_column :stripe_shared_customer_sources, :address_zip, :string, after: :address_state
  end
end
