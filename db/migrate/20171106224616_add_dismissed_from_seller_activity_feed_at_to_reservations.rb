class AddDismissedFromSellerActivityFeedAtToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :dismissed_from_buyer_sent_feed_at, :datetime, after: 'dismissed_from_buyer_activity_feed_at'
  end
end
