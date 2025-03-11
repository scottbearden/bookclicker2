class IndexUsersOnAweberAccountId < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :aweber_account_id, unique: true
  end
end
