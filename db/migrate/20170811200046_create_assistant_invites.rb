class CreateAssistantInvites < ActiveRecord::Migration[5.0]
  def change
    create_table :assistant_invites do |t|
      t.integer :member_user_id, null: false
      t.string :invitee_email, null: false
      t.datetime :invite_sent_at
      t.datetime :assistant_created_at
      t.integer :assistant_user_id
      t.timestamps
      t.index :member_user_id
      t.index :invitee_email
    end
  end
end
