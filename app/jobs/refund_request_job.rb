class RefundRequestJob
  include Sidekiq::Worker
  
  def perform(reservation_id)
    
    reservation = Reservation.find(reservation_id)
    
    return nil unless reservation.refundable_payment.present?
    
    reservation.seller_recipients.each do |recipient|
      mail = ReservationMailer.request_refund_from_seller(reservation, recipient)
      mail.deliver
      Email.create({
        mailer: mail.meta_data.mailer_id, 
        user_id: recipient.id, 
        email_address: recipient.email
      })
    end
    
  end
  
end
