class HandleSellerReservationDeclineJob
  
  def self.perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    reservation.buyer_recipients(:bookings).each do |recipient|
      ReservationMailer.notify_buyer_of_decline(reservation, recipient).deliver
    end
  end
  
end