class AddRecordedListNameToExternalReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :external_reservations, :recorded_list_name, :string, after: 'list_id'
    ExternalReservation.includes(:list).each do |res|
      res.set_recorded_list_name
      if res.recorded_list_name.blank?
        res.recorded_list_name = res.list.name
      end
      
      res.save
    end
  end
end
