class ReservationMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def confirm_reservation_payment(reservation, recipient, payment)
    pull_reservation_data(reservation)
    @recipient = recipient
    @payment = payment
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Payment succeeded for booking [#{reservation.id}]")
  end
  
  def notify_seller_of_reservation(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "You have a new booking [#{reservation.id}]")
  end
  
  def notify_seller_of_system_cancel(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "A booking has been automatically cancelled [#{reservation.id}]")
  end
  
  def notify_buyer_of_system_cancel(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your booking has been automatically cancelled [#{reservation.id}]")
  end
  
  def notify_swapper_of_swap_cancel(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your swapped booking has been cancelled [#{reservation.id}]")
  end
  
  def notify_seller_of_buyer_cancel(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "A buyer has cancelled a booking [#{reservation.id}]")
  end
  
  def notify_buyer_of_seller_cancel(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "A seller has cancelled a booking [#{reservation.id}]")
  end
  
  def confirm_swap_accept_to_buyer(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your swap request has been accepted [#{reservation.id}]")
  end
  
  def confirm_zero_dollar_accept_to_buyer(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your booking has been accepted [#{reservation.id}]")
  end
  
  def notify_buyer_of_accept_and_charge(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    @payment = reservation.refundable_payment
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your booking request has been accepted and your card has been charged [#{reservation.id}]")
  end
  
  def notify_buyer_of_accept_and_invoice(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "You have a new invoice for an accepted booking [#{reservation.id}]")
  end
  
  def notify_buyer_of_decline(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your booking has been declined [#{reservation.id}]")
  end

  def prompt_seller_to_confirm_promo(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Have you sent out your #{@reservation.inv_type} promo yet? [#{reservation.id}]")
  end

  def notify_buyer_of_promo_send_confirmation(reservation, campaign, recipient)
    pull_reservation_data(reservation)
    @campaign = campaign
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Bookclicker Promo Confirmation [#{reservation.id}]")
  end
  
  def notify_buyer_of_reschedule(reservation, date_was, recipient)
    pull_reservation_data(reservation)
    @date_was = date_was
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your #{@reservation.inv_type} promo has been rescheduled [#{reservation.id}]")
  end
  
  def notify_buyer_of_refund(reservation, recipient)
    pull_reservation_data(reservation)
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your #{@reservation.inv_type} promo has been refunded [#{reservation.id}]")
  end
  
  def request_confirmation_from_seller(reservation, recipient)
    pull_reservation_data(reservation)
    
    @buyer_author_name = reservation.book_author.presence ||  "A buyer"
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "#{@buyer_author_name} has requested promo confirmation [#{reservation.id}]")
  end
  
  def request_refund_from_seller(reservation, recipient)
    pull_reservation_data(reservation)
    
    @buyer_author_name = reservation.book_author.presence ||  "A buyer"
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "#{@buyer_author_name} has requested a refund [#{reservation.id}]")
  end
  
  private
  
  def pull_reservation_data(reservation)
    @reservation = reservation
    @list = reservation.list
    @book = reservation.book
    @seller = reservation.seller
    @buyer = reservation.buyer
    pull_swap_reservation_data(reservation) if reservation.swap_reservation.present?
  end
  
  def pull_swap_reservation_data(reservation)
    @swap_reservation = reservation.swap_reservation
    @swap_list = @swap_reservation.list
    @swap_book = @swap_reservation.book
    @swap_seller = @swap_reservation.seller
    @swap_buyer = @swap_reservation.buyer
  end
  
end
