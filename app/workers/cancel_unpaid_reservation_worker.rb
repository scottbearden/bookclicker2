class CancelUnpaidReservationWorker
  include Sidekiq::Worker

  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    if reservation.buyer_invoiced_at? && reservation.buyer_invoiced_at < BUYER_PAYMENT_HOUR_LIMIT.hours.ago && !reservation.paid?
      reservation.update!(system_cancelled_at: Time.now, system_cancelled_reason: "buyer_did_not_pay")
      
      reservation.seller_recipients(:bookings).each do |recipient|
        ReservationMailer.notify_seller_of_system_cancel(reservation, recipient).deliver
      end
      
      reservation.buyer_recipients(:bookings).each do |recipient|
        ReservationMailer.notify_buyer_of_system_cancel(reservation, recipient).deliver
      end

    end
  end
end
