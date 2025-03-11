class RecordApplicationFeeAmount < ActiveRecord::Migration[5.0]
  def change
    add_column :connect_payments, :application_fee_amount, :integer
  end
end
