class AddEmailToStripeAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :stripe_accounts, :deferred_acct_email, :string, before: 'country'
  end
end
