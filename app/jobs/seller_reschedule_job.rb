class SellerRescheduleJob
  include Sidekiq::Worker
  
  def perform(reservation_id, date_was)
    reservation = Reservation.find(reservation_id)
    reservation.buyer_recipients(:bookings).each do |recipient|
      ReservationMailer.notify_buyer_of_reschedule(reservation, date_was, recipient).deliver
    end
  end
  
end