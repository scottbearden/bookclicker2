class CreateReservations < ActiveRecord::Migration[5.0]
  def change
    create_table :reservations do |t|
      t.integer :list_id, null: false
      t.integer :book_id, null: false
      t.date :date, null: false
      t.string :inv_type, null: false
      t.integer :price
      t.text :message
      t.datetime :seller_notified_at
      t.datetime :seller_accepted_at
      t.datetime :seller_declined_at
      t.datetime :seller_cancelled_at
      t.datetime :system_cancelled_at
      t.datetime :payment_notifications_sent_at
      t.timestamps
      t.index [:list_id, :book_id]
      t.index [:book_id, :list_id]
    end
  end
end
 