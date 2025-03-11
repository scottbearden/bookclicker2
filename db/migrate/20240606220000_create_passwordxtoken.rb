class CreatePasswordxtoken < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:password_tokens)

    create_table :password_tokens, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
    end
  end
end
