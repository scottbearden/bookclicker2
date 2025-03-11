class AddTimestampsToStripeAccounts < ActiveRecord::Migration[5.0]
  def change
    add_timestamps(:stripe_accounts)
    StripeAccount.all.each(&:save)
  end
end
