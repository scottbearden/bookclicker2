class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :role, limit: 1, null: false 
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :session_token, null: false
      
      t.integer :mailchimp_user_id
      t.string :encrypted_mailchimp_access_token
      t.string :encrypted_mailchimp_access_token_iv
      t.string :mailchimp_api_dc
      t.string :mailchimp_role
      t.string :mailchimp_accountname
      t.timestamps
      t.index :role
      t.index  :email, unique: true
      t.index  :mailchimp_user_id, unique: true
      t.index :session_token, unique: true
    end
  end
end