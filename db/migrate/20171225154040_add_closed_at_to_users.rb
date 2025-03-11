class AddClosedAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :closed_at, :datetime
  end
end
