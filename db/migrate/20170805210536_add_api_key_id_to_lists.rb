class AddApiKeyIdToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :api_key_id, :integer, after: 'pen_name_id'
  end
end
