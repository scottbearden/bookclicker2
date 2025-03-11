class CreateExternalReservations < ActiveRecord::Migration[5.0]
  def change
    create_table :external_reservations do |t|
      t.integer :list_id, null: false
      t.date :date, null: false
      t.string :book_owner_name
      t.string :book_owner_email
      t.string :book_title
      t.string :inv_type, null: false, default: "date_unavailable"
      t.timestamps
      t.index :list_id
    end
  end
end
