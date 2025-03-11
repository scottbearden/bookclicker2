class AddCampaignFetchedAtToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :campaigns_fetched_at, :datetime, after: 'payment_notifications_sent_at'
  end
end
