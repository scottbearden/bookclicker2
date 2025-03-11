class CreateStripexpaymentxintent < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_payment_intents)

    create_table :stripe_payment_intents, id: :serial, primary_key: :id do |t|
      t.references :reservation, null: false, type: :integer, foreign_key: { to_table: :reservations }
      t.string :customer_id
      t.integer :amount
      t.string :currency
      t.string :intent_id, null: false
      t.string :payment_method
      t.integer :application_fee_amount
      t.string :return_url
      t.string :status, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
