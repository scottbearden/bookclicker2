class AddFiedlsToCustomersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :stripe_customers, :destination_stripe_account_id, :integer, after: 'user_id'
    add_column :stripe_customers, :default_source, :string, after: 'destination_stripe_account_id'
  end
end
