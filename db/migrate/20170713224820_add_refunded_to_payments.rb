class AddRefundedToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :connect_payments, :refunded, :integer, limit: 1, after: 'paid', default: 0
  end
end
