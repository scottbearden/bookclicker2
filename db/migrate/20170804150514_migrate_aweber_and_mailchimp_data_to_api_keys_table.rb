class MigrateAweberAndMailchimpDataToApiKeysTable < ActiveRecord::Migration[5.0]
  def change
    execute("create table aaa_users_#{Time.now.to_s.delete("- +:")} as select * from users")
    execute("create table api_keys_#{Time.now.to_s.delete("- +:")} as select * from api_keys")
    
    add_column :api_keys, :account_id, :integer, after: 'platform'
    add_column :api_keys, :api_dc, :string, after: 'account_id'
    add_column :api_keys, :encrypted_token, :string, after: 'api_dc'
    add_column :api_keys, :encrypted_token_iv, :string, after: 'encrypted_token'
    add_column :api_keys, :encrypted_secret, :string, after: 'encrypted_token_iv'
    add_column :api_keys, :encrypted_secret_iv, :string, after: 'encrypted_secret'
    
  end
end
