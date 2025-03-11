class DropReservationBuyerUserIdFromPayments < ActiveRecord::Migration[5.0]
  def change
    remove_column :connect_payments, :reservation_buyer_user_id, :integer
  end
end
