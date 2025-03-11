class ExpireReservationWorker
  include Sidekiq::Worker

  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    return unless reservation.pending?
    if reservation.created_at < SELLER_RESPONSE_DAY_LIMIT.days.ago
      reservation.update!(system_cancelled_at: Time.now, system_cancelled_reason: "seller_did_not_respond")
      
      reservation.seller_recipients(:bookings).each do |recipient|
        ReservationMailer.notify_seller_of_system_cancel(reservation, recipient).deliver
      end
      
      reservation.buyer_recipients(:bookings).each do |recipient|
        ReservationMailer.notify_buyer_of_system_cancel(reservation, recipient).deliver
      end
    else
      ExpireReservationWorker.perform_in(1.day + 5.minutes, reservation.id)
    end
  end
end
