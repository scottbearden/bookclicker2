class PromptSellerToConfirmPromoWorker
  include Sidekiq::Worker

  def perform(reservation_id, reservation_type = "system")
    
    if reservation_type == "manual"
      reservation = ExternalReservation.find(reservation_id)
    else
      reservation = Reservation.find(reservation_id)
    end

    reservation.seller_recipients(:confirmations).each do |recipient|
      mail = ReservationMailer.prompt_seller_to_confirm_promo(reservation, recipient)
      mail.deliver
      Email.create!({
        mailer: mail.meta_data.mailer_id, 
        user_id: recipient.id, 
        email_address: recipient.email 
      })
    end
  end
end
