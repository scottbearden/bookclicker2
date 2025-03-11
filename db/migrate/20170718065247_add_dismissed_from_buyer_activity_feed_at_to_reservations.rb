class AddDismissedFromBuyerActivityFeedAtToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :dismissed_from_buyer_activity_feed_at, :datetime, after: 'campaigns_fetched_at'
  end
end
