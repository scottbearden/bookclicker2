class CreateAssistantxpaymentxrequest < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:assistant_payment_requests)

    create_table :assistant_payment_requests, id: :serial, primary_key: :id do |t|
      t.integer :users_assistant_id, null: false
      t.integer :pay_amount, null: false
      t.datetime :accepted_at
      t.string :stripe_subscription_id
      t.integer :subscription_plan_id
      t.datetime :declined_at
      t.datetime :agreement_cancelled_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :last_known_subscription_status
      t.datetime :last_known_subscription_status_at
    end
  end
end
