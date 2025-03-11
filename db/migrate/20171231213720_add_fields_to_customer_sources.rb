class AddFieldsToCustomerSources < ActiveRecord::Migration[5.0]
  def change
    add_column :stripe_shared_customer_sources, :country, :string, after: :funding
    add_column :stripe_shared_customer_sources, :cvc_check, :string, after: :last4
    add_column :stripe_shared_customer_sources, :address_zip_check, :string, after: :address_zip
  end
end
