class AddPaidOfferBooleanToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :payment_offer, :integer, limit: 1, default: 1, null: false, after: 'premium'
  end
end
