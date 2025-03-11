class HandleSellerReservationAcceptJob
  
  def self.perform(reservation_id)
    reservation = Reservation.find(reservation_id)

    if reservation.swap_offer_accepted?
      reservation.buyer_recipients(:bookings).each do |recipient|
        ReservationMailer.confirm_swap_accept_to_buyer(reservation, recipient).deliver
      end
    elsif reservation.payment_offer_accepted?
      if reservation.zero_dollar_offer?
        reservation.buyer_recipients(:bookings).each do |recipient|
          ReservationMailer.confirm_zero_dollar_accept_to_buyer(reservation, recipient).deliver
        end
      elsif reservation.paid?
        reservation.buyer_recipients(:bookings).each do |recipient|
          ReservationMailer.notify_buyer_of_accept_and_charge(reservation, recipient).deliver
        end
      else
        InvoiceBuyerJob.perform(reservation_id) if reservation.seller_stripe_account.present?
      end
    end
  end

end

