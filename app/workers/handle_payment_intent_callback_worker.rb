class HandlePaymentIntentCallbackWorker
  include Sidekiq::Worker

  def perform(stripe_pi_object_id, seller_stripe_acct_id)
    stripe_pi_object = Stripe::PaymentIntent.retrieve(stripe_pi_object_id, stripe_account: seller_stripe_acct_id)
    stripe_payment_intent = StripePaymentIntent.find_by(intent_id: stripe_pi_object.id)

    if stripe_payment_intent.present?
      StripePaymentIntent.sync_with_api(stripe_pi_object)
    else
      reservation = Reservation.find(stripe_pi_object.metadata['reservation_id'])
      StripePaymentIntent.create_from_stripe_object!(stripe_pi_object, reservation)
    end

  rescue Stripe::InvalidRequestError => e
    if e.message.include?('No such payment_intent')
      return
    else
      raise e
    end
  end
end
