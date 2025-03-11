class AddStripeAcctIdToPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :subscription_plans, :stripe_acct_id, :string, :after => 'name'
  end
end
