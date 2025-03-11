class AddBuyerCancelledAtToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :buyer_cancelled_at, :datetime, after: 'seller_declined_at'
  end
end
