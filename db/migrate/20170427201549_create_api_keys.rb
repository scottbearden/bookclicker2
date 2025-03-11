class CreateApiKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :api_keys do |t|
      t.integer :user_id, null: false
      t.string :platform, null: false
      t.integer :status, limit: 1, null: false, default: 1
      t.string :encrypted_key, null: false
      t.string :encrypted_key_iv, null: false
      t.timestamps
      t.index :platform
      t.references :user, foreign_key: true
    end
  end
end
