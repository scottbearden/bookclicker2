class AddIndexOnConvId < ActiveRecord::Migration[5.0]
  def change
    add_index :conversation_user_pen_names, :conversation_id
  end
end
