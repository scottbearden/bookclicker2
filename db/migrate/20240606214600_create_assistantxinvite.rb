class CreateAssistantxinvite < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:assistant_invites)

    create_table :assistant_invites, id: :serial, primary_key: :id do |t|
      t.integer :member_user_id, null: false
      t.string :pen_name
      t.string :invitee_email, null: false
      t.datetime :invite_sent_at
      t.datetime :assistant_created_at
      t.integer :assistant_user_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
