class IndexPaymentsOnChargeId < ActiveRecord::Migration[5.0]
  def change
    add_index :connect_payments, :charge_id, unique: true
  end
end
