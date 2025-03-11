class AddSwapFieldsToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :swap_offer, :integer, limit: 1, default: 0, null: false, after: 'premium'
    add_column :reservations, :swap_offer_list_id, :integer, after: 'swap_offer'
    add_column :reservations, :swap_offer_solo, :integer, limit: 1, default: 0, after: 'swap_offer_list_id'
    add_column :reservations, :swap_offer_feature, :integer, limit: 1, default: 0, after: 'swap_offer_solo'
    add_column :reservations, :swap_offer_mention, :integer, limit: 1, default: 0, after: 'swap_offer_feature'
    add_column :reservations, :swap_accepted_at, :datetime, after: 'swap_offer_mention'
    add_column :reservations, :swap_reservation_id, :integer, after: 'swap_accepted_at'
  end
end
