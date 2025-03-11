class CreateMailboxerxnotification < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:mailboxer_notifications)

    create_table :mailboxer_notifications, id: :serial, primary_key: :id do |t|
      t.string :type
      t.text :body
      t.string :subject
      t.string :sender_type
      t.integer :sender_id
      t.references :conversation, type: :integer, foreign_key: { to_table: :mailboxer_conversations }
      t.integer :draft
      t.string :notification_code
      t.string :notified_object_type
      t.integer :notified_object_id
      t.string :attachment
      t.datetime :updated_at, null: false
      t.datetime :created_at, null: false
      t.integer :global
      t.datetime :expires
    end
  end
end
