class CreateMailboxerxreceipt < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:mailboxer_receipts)

    create_table :mailboxer_receipts, id: :serial, primary_key: :id do |t|
      t.string :receiver_type
      t.integer :receiver_id
      t.references :notification, null: false, type: :integer, foreign_key: { to_table: :mailboxer_notifications }
      t.integer :is_read
      t.integer :trashed
      t.integer :deleted
      t.string :mailbox_type
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :is_delivered
      t.string :delivery_method
      t.string :message_id
    end
  end
end
