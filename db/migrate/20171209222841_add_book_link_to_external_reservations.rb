class AddBookLinkToExternalReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :external_reservations, :book_link, :string, after: 'book_title'
  end
end
