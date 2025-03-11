class AddInvoiceDataToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :buyer_invoiced_at, :datetime, after: 'seller_notified_at'
  end
end
