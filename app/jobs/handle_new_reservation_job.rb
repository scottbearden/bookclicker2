class HandleNewReservationJob
  include Sidekiq::Worker

  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    reservation.seller_recipients(:bookings).each do |recipient|
      ReservationMailer.notify_seller_of_reservation(reservation, recipient).deliver
      reservation.update!(seller_notified_at: Time.now)
    end
    
    ExpireReservationWorker.perform_in(SELLER_RESPONSE_DAY_LIMIT.days + 5.minutes, reservation.id)
  end
  

end
