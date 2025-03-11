class AddRecordedListNameToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :recorded_list_name, :string, after: 'list_id'
    Reservation.all.each do |res|
      res.set_recorded_list_name
      res.save
    end
  end
end
