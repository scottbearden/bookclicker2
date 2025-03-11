class CreateReservationsCampaignsConfirmations < ActiveRecord::Migration[5.0]
  def change
    create_table :promo_send_confirmations do |t|
    	t.integer :reservation_id, null: false
      t.integer :campaign_id
      t.datetime :seller_confirmed_at
      t.datetime :buyer_confirmed_at
    end
    add_index :promo_send_confirmations, :reservation_id
    remove_column :campaigns, :reservation_id
    remove_column :campaigns, :seller_confirmed_at
  end
end
