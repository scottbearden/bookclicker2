class AddWeberFieldsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :aweber_account_id, :string, after: 'session_token'
    add_column :users, :aweber_token, :string, after: 'aweber_account_id'
    add_column :users, :encrypted_aweber_secret, :string, after: 'aweber_token'
    add_column :users, :encrypted_aweber_secret_iv, :string, after: 'encrypted_aweber_secret'
  end
end
