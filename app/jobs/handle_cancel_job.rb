class HandleCancelJob
  
  def self.perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    if reservation.swap_reservation.present? && reservation.cancelled?
      reservation.buyer_recipients(:bookings).each do |recipient|
        mail = ReservationMailer.notify_swapper_of_swap_cancel(reservation, recipient)
        mail.deliver
        Email.create({
          user_id: recipient.id,
          mailer: mail.meta_data.mailer_id, 
          email_address: recipient.email
        })
      end
    elsif reservation.buyer_cancelled_at?
      reservation.seller_recipients(:bookings).each do |recipient|
        mail = ReservationMailer.notify_seller_of_buyer_cancel(reservation, recipient)
        mail.deliver
        Email.create({
          user_id: recipient.id,
          mailer: mail.meta_data.mailer_id, 
          email_address: recipient.email
        })
      end
    elsif reservation.seller_cancelled_at?
      reservation.buyer_recipients(:bookings).each do |recipient|
        mail = ReservationMailer.notify_buyer_of_seller_cancel(reservation, recipient)
        mail.deliver
        Email.create({
          user_id: recipient.id,
          mailer: mail.meta_data.mailer_id, 
          email_address: recipient.email
        })
      end
    end
    
  end
  
end
