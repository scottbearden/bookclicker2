class DropSwapAcceptedAtFromReservations < ActiveRecord::Migration[5.0]
  def change
    remove_column :reservations, :swap_accepted_at
  end
end
