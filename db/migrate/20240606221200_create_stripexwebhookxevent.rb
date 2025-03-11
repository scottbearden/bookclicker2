class CreateStripexwebhookxevent < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_webhook_events)

    create_table :stripe_webhook_events, id: :serial, primary_key: :id do |t|
      t.text :data
      t.string :event_type
      t.string :account
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
