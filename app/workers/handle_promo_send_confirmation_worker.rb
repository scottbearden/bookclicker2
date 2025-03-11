class HandlePromoSendConfirmationWorker
  include Sidekiq::Worker

  def perform(reservation_id, reservation_type)
    reservation = reservation_type.constantize.find(reservation_id)
    
    # Resque.remove_delayed_selection(self){ |obj| obj == [reservation_id, reservation_type]  }
    
    campaign = reservation.get_confirmed_campaign
    
    raise "Could not find campaign for #{self} - Res ##{reservation.id}" unless campaign.present?
    
    if reservation.is_a?(Reservation)
      reservation.buyer_recipients(:bookings).each do |recipient|
        mail = ReservationMailer.notify_buyer_of_promo_send_confirmation(reservation, campaign, recipient)
        mail.deliver
        Email.create!({
          mailer: mail.meta_data.mailer_id, 
          user_id: recipient.id, 
          email_address: recipient.email 
        })
      end
    elsif reservation.is_a?(ExternalReservation)
      if can_send_to_email?(reservation.book_owner_email)
        recipient = reservation.find_or_invent_buyer
        mail = ReservationMailer.notify_buyer_of_promo_send_confirmation(reservation, campaign, recipient)
        mail.deliver
        Email.create!({
          mailer: mail.meta_data.mailer_id, 
          user_id: (recipient.id || -1), 
          email_address: recipient.email 
        })
      end
    end
  end
  
  def can_send_to_email?(email)
    Email.valid?(email)
  end
  
  def self.job_delay
    Rails.env.production? ? 100.minutes : 2.minutes
  end
  
end
