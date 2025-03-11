class ConfirmationRequestJob 
  include Sidekiq::Worker
  
  def perform(reservation_id)
    
    reservation = Reservation.find(reservation_id)
    reservation.seller_recipients(:confirmations).each do |recipient|
      mail = ReservationMailer.request_confirmation_from_seller(reservation, recipient)
      mail.deliver
      Email.create({
        mailer: mail.meta_data.mailer_id, 
        user_id: recipient.id, 
        email_address: recipient.email
      })
    end
    
  end
  
end
