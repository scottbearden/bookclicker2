class CreateStripexaccount < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_accounts)

    create_table :stripe_accounts, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.string :acct_id, null: false
      t.string :deferred_acct_email
      t.string :country
      t.integer :deleted, null: false
      t.string :publishable_key
      t.string :refresh_token
      t.string :access_token
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
