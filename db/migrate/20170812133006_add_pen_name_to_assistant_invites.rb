class AddPenNameToAssistantInvites < ActiveRecord::Migration[5.0]
  def change
    add_column :assistant_invites, :pen_name, :string, after: 'member_user_id'
  end
end
