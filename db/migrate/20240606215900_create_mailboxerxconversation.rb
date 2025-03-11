class CreateMailboxerxconversation < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:mailboxer_conversations)

    create_table :mailboxer_conversations, id: :serial, primary_key: :id do |t|
      t.string :subject
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
