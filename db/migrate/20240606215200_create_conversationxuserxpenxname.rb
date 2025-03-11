class CreateConversationxuserxpenxname < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:conversation_user_pen_names)

    create_table :conversation_user_pen_names, id: :serial, primary_key: :id do |t|
      t.integer :conversation_id, null: false
      t.integer :receipt_id, null: false
      t.integer :receipt_pen_name_id, null: false
      t.integer :sender_pen_name_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
