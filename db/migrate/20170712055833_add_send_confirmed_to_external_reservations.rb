class AddSendConfirmedToExternalReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :external_reservations, :author_emailed_at, :datetime, after: 'inv_type'
    add_column :external_reservations, :send_confirmed_at, :datetime, after: 'inv_type'
    
  end
end
