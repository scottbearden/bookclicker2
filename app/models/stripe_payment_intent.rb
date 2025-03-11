class StripePaymentIntent < ApplicationRecord

  include StripeIntentConcern

  belongs_to :reservation
  has_many :connect_payments
  validates :reservation, :intent_id, :status, presence: true

  def self.create_from_reservation(reservation, payment_method, is_buyer_action)
    raise "Attempting to charge for paid booking #{reservation.id}" if reservation.paid?
    raise "Could not locate seller's Stripe account for booking #{reservation.id}" if reservation.seller_stripe_account.blank?
    off_session = !is_buyer_action
    raise "Must pass in payment method if charging buyer off_session. Booking #{reservation.id}" if off_session && payment_method.blank?
    
    customer_id = nil
    if off_session
      cloned_payment_method = Stripe::PaymentMethod.create({
        customer: reservation.buyer.bc_customer.customer_id,
        payment_method: payment_method,
      }, {
        stripe_account: reservation.seller_stripe_acct_id,
      })
      payment_method = cloned_payment_method.id
      customer_id = cloned_payment_method.customer
    end
    
    stripe_pi_object = Stripe::PaymentIntent.create({
      amount: reservation.stripe_payment_amount,
      off_session: off_session,
      confirm: payment_method.present?,
      currency: 'usd',
      customer: customer_id,
      metadata: { reservation_id: reservation.id, payment_method: payment_method, is_buyer_action: is_buyer_action },
      payment_method_types: ['card'],
      payment_method: payment_method,
      statement_descriptor: "Booking #{reservation.id}",
      application_fee_amount: (reservation.stripe_payment_amount*0.10).round,
    }, stripe_account: reservation.seller_stripe_acct_id)
    stripe_payment_intent = create_from_stripe_object!(stripe_pi_object, reservation)
    [stripe_payment_intent, stripe_pi_object]
  rescue Stripe::CardError => e
    PaymentProcessor.record_card_error(e, payment_method, reservation.id)
    [OpenStruct.new(succeeded?: false, status: e.message), OpenStruct.new]
  end

  def self.create_from_stripe_object!(stripe_pi_object, reservation)
    stripe_payment_intent = create!(
      reservation: reservation,
      customer_id: stripe_pi_object.customer,
      amount: stripe_pi_object.amount,
      currency: stripe_pi_object.currency,
      intent_id: stripe_pi_object.id,
      status: stripe_pi_object.status,
      payment_method: stripe_pi_object.payment_method,
      application_fee_amount: stripe_pi_object.application_fee_amount,
    )
    stripe_payment_intent.record_charges(stripe_pi_object)
    stripe_payment_intent
  end

  def self.sync_with_api(stripe_object)
    stripe_payment_intent = StripePaymentIntent.find_by!(intent_id: stripe_object.id)
    stripe_payment_intent.update!(status: stripe_object.status, payment_method: stripe_object.payment_method, customer_id: stripe_object.customer)
    stripe_payment_intent.record_charges(stripe_object)
    stripe_payment_intent
  end

  def record_charges(stripe_object)
    result = []
    stripe_object.charges.select { |sc| sc.status == 'succeeded' }.each do |stripe_charge_object|
      connect_payment = ConnectPayment.where(charge_id: stripe_charge_object.id).first_or_initialize
      connect_payment.reservation = self.reservation
      connect_payment.stripe_payment_intent = self
      connect_payment.update_from_stripe_charge!(stripe_charge_object)
      result << connect_payment
    end
    result
  end

end
