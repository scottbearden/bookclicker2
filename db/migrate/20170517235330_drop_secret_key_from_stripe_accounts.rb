class DropSecretKeyFromStripeAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :stripe_accounts, :secret_key
  end
end
