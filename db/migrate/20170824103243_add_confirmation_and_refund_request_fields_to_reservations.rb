class AddConfirmationAndRefundRequestFieldsToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :confirmation_requested_at, :datetime, after: 'campaigns_fetched_at'
    add_column :reservations, :refund_requested_at, :datetime, after: 'confirmation_requested_at'
  end
end
