class AddUniquenessToApiKeys < ActiveRecord::Migration[5.0]
  def change
    add_index :api_keys, [:user_id, :platform], unique: true
  end
end
