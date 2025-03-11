class AddCampaignsFetchedAtToExternal < ActiveRecord::Migration[5.0]
  def change
    add_column :external_reservations, :campaigns_fetched_at, :datetime, after: 'send_confirmed_at'
    remove_column :external_reservations, :send_confirmed_at
    remove_column :external_reservations, :author_emailed_at
  end
end
