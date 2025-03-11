class CreateApixkey < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:api_keys)

    create_table :api_keys, id: :serial, primary_key: :id do |t|
      t.integer :user_id
      t.string :platform, null: false
      t.integer :account_id
      t.string :api_dc
      t.integer :status, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :encrypted_token
      t.string :encrypted_token_iv
      t.string :encrypted_secret
      t.string :encrypted_secret_iv
      t.string :encrypted_key
      t.string :encrypted_key_iv
    end
  end
end
