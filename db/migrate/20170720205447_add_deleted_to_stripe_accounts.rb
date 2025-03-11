class AddDeletedToStripeAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :stripe_accounts, :deleted, :integer, limit: 1, default: 0, null: false, after: 'acct_id'
  end
end
