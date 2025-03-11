class CreateStripePaymentIntents < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_payment_intents do |t|
      t.references :reservation, foreign_key: true, null: false
      t.string :customer_id
      t.integer :amount
      t.string :currency
      t.string :intent_id, null: false
      t.string :payment_method
      t.integer :application_fee_amount
      t.string :return_url
      t.string :status, null: false
      t.timestamps
      t.index [:intent_id], unique: true
    end
    add_column :connect_payments, :stripe_payment_intent_id, :integer
    add_index :connect_payments, :stripe_payment_intent_id
  end
end
