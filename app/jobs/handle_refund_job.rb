class HandleRefundJob
  include Sidekiq::Worker
  
  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    reservation.buyer_recipients.each do |recipient|
      ReservationMailer.notify_buyer_of_refund(reservation, recipient).deliver
    end
  end
  
end