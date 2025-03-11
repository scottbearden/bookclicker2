class AddIndexUserIdOnStripeAccounts < ActiveRecord::Migration[5.0]
  def change
    execute("create index idx_stripe_accounts_on_user_id on stripe_accounts(user_id)")
  end
end
