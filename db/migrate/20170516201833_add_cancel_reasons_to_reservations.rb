class AddCancelReasonsToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :system_cancelled_reason, :string, after: 'system_cancelled_at'
    add_column :reservations, :seller_cancelled_reason, :string, after: 'seller_cancelled_at'
  end
end
