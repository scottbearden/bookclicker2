class MakePromoSendConfirmationsPolymorphic < ActiveRecord::Migration[5.0]
  def change
    add_column :promo_send_confirmations, :reservation_type, :string, null: false, default: 'Reservation', after: 'reservation_id'
  end
end
