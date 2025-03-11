class CreateStripeWebhookEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_webhook_events do |t|
      t.text :data
      t.string :event_type
      t.string :account
      t.timestamps
    end
  end
end
