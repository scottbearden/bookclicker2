class CreateMailboxerxconversationxoptxout < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:mailboxer_conversation_opt_outs)

    create_table :mailboxer_conversation_opt_outs, id: :serial, primary_key: :id do |t|
      t.string :unsubscriber_type
      t.integer :unsubscriber_id
      t.references :conversation, type: :integer, foreign_key: { to_table: :mailboxer_conversations }
    end
  end
end
