class AddEmailVerifiedAtToUsersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_verified_at, :datetime, after: 'email'
  end
end
