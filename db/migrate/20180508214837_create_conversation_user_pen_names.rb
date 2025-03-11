class CreateConversationUserPenNames < ActiveRecord::Migration[5.0]
  def change
    create_table :conversation_user_pen_names do |t|
      t.integer :conversation_id, null: false
      t.integer :receipt_id, null: false
      t.integer :receipt_pen_name_id, null: false
      t.integer :sender_pen_name_id, null: false
      
      t.timestamps
    end
  end
end
