class DropFieldsFromUser < ActiveRecord::Migration[5.0]
  def change
    execute("create table backup.users_pre_mc_drop as select * from users")
    remove_column :users, :aweber_account_id
    remove_column :users, :aweber_token
    remove_column :users, :encrypted_aweber_secret
    remove_column :users, :encrypted_aweber_secret_iv
    remove_column :users, :mailchimp_user_id
    remove_column :users, :mailchimp_api_dc
    remove_column :users, :mailchimp_role
    remove_column :users, :mailchimp_accountname
    remove_column :users, :encrypted_mailchimp_access_token
    remove_column :users, :encrypted_mailchimp_access_token_iv
  end
end
