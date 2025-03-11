class ChangeDefaultExtReservationType < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:external_reservations, :inv_type, :mention)
  end
end
