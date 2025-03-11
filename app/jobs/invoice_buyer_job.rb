class InvoiceBuyerJob
  
  def self.perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    
    reservation.buyer_recipients.each do |recipient|
      ReservationMailer.notify_buyer_of_accept_and_invoice(reservation, recipient).deliver
    end
    
    reservation.update!(buyer_invoiced_at: Time.now)
    CancelUnpaidReservationWorker.perform_in(BUYER_PAYMENT_HOUR_LIMIT.hours + 5.minutes, reservation_id)
  end
  
end