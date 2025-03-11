class CreateReservation < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:reservations)

    create_table :reservations, id: :serial, primary_key: :id do |t|
      t.integer :list_id, null: false
      t.string :recorded_list_name
      t.integer :book_id, null: false
      t.datetime :seller_notified_at
      t.datetime :buyer_invoiced_at
      t.datetime :seller_accepted_at
      t.datetime :seller_declined_at
      t.datetime :buyer_cancelled_at
      t.datetime :seller_cancelled_at
      t.text :seller_cancelled_reason
      t.datetime :system_cancelled_at
      t.string :system_cancelled_reason
      t.datetime :campaigns_fetched_at
      t.datetime :confirmation_requested_at
      t.datetime :refund_requested_at
      t.datetime :dismissed_from_buyer_activity_feed_at
      t.datetime :dismissed_from_buyer_sent_feed_at
      t.string :inv_type, null: false
      t.date :date, null: false
      t.text :message
      t.text :reply_message
      t.integer :price
      t.integer :premium
      t.integer :payment_offer, null: false
      t.integer :swap_offer, null: false
      t.integer :swap_offer_list_id
      t.integer :swap_offer_solo
      t.integer :swap_offer_feature
      t.integer :swap_offer_mention
      t.integer :swap_reservation_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
