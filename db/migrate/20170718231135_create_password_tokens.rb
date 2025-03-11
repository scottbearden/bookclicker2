class CreatePasswordTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :password_tokens do |t|
      t.integer :user_id, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.index :token, unique: true
    end
  end
end
