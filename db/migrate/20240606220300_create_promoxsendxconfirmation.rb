class CreatePromoxsendxconfirmation < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:promo_send_confirmations)

    create_table :promo_send_confirmations, id: :serial, primary_key: :id do |t|
      t.integer :reservation_id, null: false
      t.string :reservation_type, null: false
      t.integer :campaign_id
      t.string :campaign_preview_url
      t.datetime :seller_confirmed_at
      t.datetime :buyer_confirmed_at
    end
  end
end
