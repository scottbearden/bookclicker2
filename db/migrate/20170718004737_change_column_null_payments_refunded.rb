class ChangeColumnNullPaymentsRefunded < ActiveRecord::Migration[5.0]
  def change
    change_column_null :connect_payments, :refunded, false
  end
end
