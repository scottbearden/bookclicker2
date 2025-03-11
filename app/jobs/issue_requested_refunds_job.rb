class IssueRequestedRefundsJob

  def self.perform
    puts "began IssueRequestedRefundsJob at #{Time.now}"
    reservations = Reservation
                   .includes(:promo_send_confirmation, :connect_payments)
                   .where("refund_requested_at < NOW() - interval 24 hour")
                   
    reservations.select(&:prohibitive_refund_request?).each do |booking|
      puts "Refund #{booking.refundable_payment.id}"
      PaymentProcessor.refund(booking.refundable_payment)
    end
    puts "ended IssueRequestedRefundsJob at #{Time.now}"
  end

end