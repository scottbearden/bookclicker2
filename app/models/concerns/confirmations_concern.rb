module ConfirmationsConcern
  extend ActiveSupport::Concern
  
  included do
    scope :campaigns_fetched, -> { where.not(campaigns_fetched_at: nil) }
    scope :campaigns_not_fetched, -> { where(campaigns_fetched_at: nil) }
    scope :in_last_months, -> (num_months) { where("date > ?", num_months.months.ago) }
    has_one :confirmed_campaign, through: :promo_send_confirmation, source: :campaign
  end
  
  def send_confirmed?
    promo_send_confirmation.present?
  end
  
  def send_unconfirmed?
    !send_confirmed?
  end
  
  def needs_confirm?
    campaigns_fetched_at? && !send_confirmed?
  end
  
  def confirm_promos_link
    "#{SITE_URL}/confirm_promos?resId=#{self.id}"
  end

  def confirmed_campaign_id
    confirmed_campaign.try(:id)
  end
  
  def manual_campaign_preview_url
    promo_send_confirmation.try(:campaign_preview_url)
  end
  
  def seller_recipients(filter = nil)
    result = seller.self_with_assistants.select(&:email_verified?)
    
    if filter == :confirmations
      result.select(&:confirmations_subscribed?)
    elsif filter == :bookings
      result.select(&:bookings_subscribed?)
    else
      result
    end
  end
  
  def get_confirmed_campaign
    return nil unless self.promo_send_confirmation.present?
    campaign = self.confirmed_campaign || Campaign.new
    campaign.preview_url ||= self.promo_send_confirmation.campaign_preview_url
    campaign
  end
  
end