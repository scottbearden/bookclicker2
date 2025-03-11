class PromoSendConfirmation < ApplicationRecord

  belongs_to :reservation
  belongs_to :campaign
  
  scope :internal, -> { where(reservation_type: 'Reservation') }
  scope :external, -> { where(reservation_type: 'ExternalReservation') }
  
  validate :valid_confirmation

  def valid_confirmation
    if self.campaign_id.blank? && self.campaign_preview_url.blank?
      errors.add(:base, "Invalid campaign info for promo send confirmation")
    end
  end

end