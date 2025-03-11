class AddPreviewLinkToPromoSendConfirmations < ActiveRecord::Migration[5.0]
  def change
    add_column :promo_send_confirmations, :campaign_preview_url, :string, after: 'campaign_id'
  end
end
