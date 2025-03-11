class CreateConnectxpayment < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:connect_payments)

    create_table :connect_payments, id: :serial, primary_key: :id do |t|
      t.integer :reservation_id, null: false
      t.string :charge_id, null: false
      t.string :destination_acct_id, null: false
      t.integer :amount
      t.string :currency
      t.string :application_fee
      t.string :application
      t.integer :paid
      t.integer :refunded, null: false
      t.string :card_id
      t.string :last4
      t.string :funding
      t.integer :exp_month
      t.integer :exp_year
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :stripe_payment_intent_id
      t.integer :application_fee_amount
      t.integer :destination_charge, null: false
    end
  end
end
