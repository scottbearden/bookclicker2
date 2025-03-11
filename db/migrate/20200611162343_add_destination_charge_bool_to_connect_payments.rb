class AddDestinationChargeBoolToConnectPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :connect_payments, :destination_charge, :boolean, default: false, null: false
    execute("UPDATE connect_payments set destination_charge = true WHERE stripe_payment_intent_id IS NOT NULL")
  end
end
