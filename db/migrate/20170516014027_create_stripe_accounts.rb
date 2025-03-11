class CreateStripeAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_accounts do |t|
      t.integer :user_id, null: false
      t.string :acct_id, null: false
      t.string :publishable_key
      t.string :secret_key
      t.string :refresh_token
      t.string :access_token
      t.index :acct_id, unique: true
    end
  end
end
