class IndexReservationsOnListAndAndDates < ActiveRecord::Migration[5.0]
  def change
    add_index :reservations, [:list_id, :date]
    add_index :external_reservations, [:list_id, :date]
  end
end
