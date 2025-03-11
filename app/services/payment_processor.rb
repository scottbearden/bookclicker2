class PaymentProcessor

  def self.record_card_error(error, card_id, reservation_id)
    error_json = error.json_body[:error]
    StripeCardError.create(
      reservation_id: reservation_id,
      card: card_id,
      charge: error_json[:charge],
      message: error_json[:message],
      error_type: error_json[:type],
      error_code: error_json[:code],
      decline_code: error_json[:decline_code]   
    )
  rescue
  end
  
  def self.process_assistant_payment_request(stripe_token, users_assistant, payment_request)
    member = users_assistant.user
    assistant = users_assistant.assistant
    return OpenStruct.new(success: false, failure_message: "Assistant must have a Stripe Account set up") unless assistant.stripe_account.present?
    
    res = StripeAccountManager.create_customer(
           stripe_token, member, 
           assistant.stripe_account, 
           "Member #{member.id} accepting payment_request #{payment_request.id}")
           
    if res.success
      stripe_plan = payment_request.create_plan
      stripe_subscription = Stripe::Subscription.create({
        :customer => res.customer.cus_id,
        :plan => stripe_plan.stripe_plan_id,
        :application_fee_percent => 2,
      }, :stripe_account => assistant.stripe_account.acct_id)
      
      if stripe_subscription["failure_message"].present?
        return OpenStruct.new(success: false, failure_message: stripe_subscription["failure_message"])
      else
        if payment_request.can_terminate_subscription?
          payment_request.terminate_active_subscription
        else
          HandlePaymentPlanAcceptJob.perform_async(payment_request.id)
        end
        payment_request.update({
          accepted_at: Time.now,
          agreement_cancelled_at: nil,
          stripe_subscription_id: stripe_subscription["id"],
          subscription_plan_id: stripe_plan.id,
          last_known_subscription_status: stripe_subscription["status"],
          last_known_subscription_status_at: Time.now
        })
        OpenStruct.new(success: true, payment_request: payment_request)
      end
    else
      OpenStruct.new(success: false, failure_message: res.failure_message)
    end
  end
  
  def self.refund(payment)
    # https://stripe.com/docs/connect/destination-charges#issuing-refunds
    begin
      stripe_refund = if payment.destination_charge?
        Stripe::Refund.create(charge: payment.charge_id, reverse_transfer: true)
      else
        Stripe::Refund.create({charge: payment.charge_id}, stripe_account: payment.destination_acct_id)
      end
    rescue Stripe::InvalidRequestError => e
      if e.message.to_s.match?('s already')
        payment.update!(refunded: 1)
        return OpenStruct.new(success: false, failure_message: e.message)
      else
        raise e
      end
    end
      
    payment.update!(refunded: 1)
    payment.reservation.update!(seller_cancelled_at: Time.now)
    refund = ConnectRefund.create!(
      refund_id: stripe_refund.id,
      amount: stripe_refund.amount,
      balance_transaction: stripe_refund.balance_transaction,
      charge_id: stripe_refund.charge,
      currency: stripe_refund.currency,
      metadata: stripe_refund.metadata,
      status: stripe_refund.status
    )
    OpenStruct.new(success: true, refund: refund, payment: payment)
  end
  
end
