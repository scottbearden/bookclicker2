class AddDefaultToStripeSharedCustomerSources < ActiveRecord::Migration[5.0]
  def change
    add_column :stripe_shared_customer_sources, :default, :integer, limit: 1, after: 'deleted'
  end
end
