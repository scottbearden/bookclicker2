class IndexReservationsOnAcceptedAt < ActiveRecord::Migration[5.0]
  def change
  	add_index :reservations, [:list_id, :seller_accepted_at]
  end
end
