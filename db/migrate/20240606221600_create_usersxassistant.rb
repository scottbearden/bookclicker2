class CreateUsersxassistant < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:users_assistants)

    create_table :users_assistants, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.integer :assistant_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
