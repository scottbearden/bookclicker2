class StripeController < ApplicationController
  
  skip_before_action :verify_authenticity_token, only: [:external_account_deleted, :external_account_deauthorized, :external_account_updated, :payment_intent_callback]
  before_action :record_stripe_webhook_event, only: [:external_account_deleted, :external_account_deauthorized, :external_account_updated]
  
  before_action :require_current_member_user, only: [:create_card, :charge_buyer]
  before_action :block_assistant, only: [:create_card]
  
  def callback
    if params[:error].present?
      flash[:error] = "There was an error with your Stripe request: #{params[:error]}"
      return redirect_to root_path
    elsif params[:stripe_provisioning_activation].present? && params[:stripe_user_id].present? #deferred activation
      deferred_account_activation
    elsif params[:code].present? #regular activation, will have params[:state] as well
      regular_account_activation
    else
      flash[:error] = "Unkown Stripe action.  Please report error to info@bookclicker.com"
      return redirect_to root_path
    end
  end

  def payment_intent_callback
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV['stripe_pi_webhook_secret']
      )
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      status 400
      return
    end
    HandlePaymentIntentCallbackWorker.perform_in(1.minute, event.data.object.id, event.account)
    StripeWebhookEvent.create(event_type: event.type, data: event.data.to_json)
  end
  
  def charge_buyer # payment info is used one-time to pay for booking
    @reservation = Reservation.find(params[:reservation_id])
    stripe_pi_object = Stripe::PaymentIntent.retrieve(params[:stripe_payment_intent_id], stripe_account: @reservation.seller_stripe_acct_id)
    stripe_payment_intent = StripePaymentIntent.sync_with_api(stripe_pi_object)
    if stripe_payment_intent.succeeded?
      return on_successful_reservation_payment(@reservation)
    elsif stripe_payment_intent.has_next_action?
      error = report_stripe_unexpected_action_error(stripe_pi_object)
      return on_failed_reservation_payment(@reservation, error)
    else
      return on_failed_reservation_payment(@reservation, "Payment is in a status of #{stripe_payment_intent.status}")
    end
  rescue Stripe::InvalidRequestError, Stripe::PermissionError => e
    return on_failed_reservation_payment(@reservation, e.message)
  end
  
  def on_successful_reservation_payment(reservation)
    flash[:success] = "Your payment was processed successfully!"
    ListSubscription.handle_paid_reservation(reservation)
    redirect_to info_reservation_path(reservation)
  end
  
  def on_failed_reservation_payment(reservation, failure_message)
    flash[:error] = failure_message || "There was an error processing your payment."
    return redirect_to pay_reservation_path(@reservation)
  end
  
  def begin_assistant_payment_plan
    stripeToken = params[:stripeToken]
    users_assistant = UsersAssistant.find(params[:users_assistant_id])
    payment_request = AssistantPaymentRequest.find(params[:assistant_payment_request_id])
    if_error_path = "/assistant_requests/#{users_assistant.id}/accept/#{payment_request.id}"
    
    if !stripeToken
      flash[:error] = "There was an issue processing your payment info [Payment Request ##{payment_request.id}]"
      return redirect_to if_error_path
    else
      res = PaymentProcessor.process_assistant_payment_request(stripeToken, users_assistant, payment_request)
      if res.success
        flash[:success] = "This payment method was accepted!.  Your weekly payment plan with #{users_assistant.assistant.full_name_or_email} is now active"
        return redirect_to "/profile"
      else
        flash[:error] = (res.failure_message || "There was an error processing your payment info.") + " [Payment Request ##{payment_request.id}]"
        return redirect_to if_error_path
      end
    end
  rescue Stripe::InvalidRequestError, Stripe::PermissionError => e
    flash[:error] = e.message
    return redirect_to if_error_path
  end
  
  def external_account_deleted
    if acct_id_from_webhook.present?
      int_stripe_acct = StripeAccount.unscoped.find_by(acct_id: acct_id_from_webhook)
      int_stripe_acct.update!(deleted: 1) if int_stripe_acct.present?
    end
    return render json: { success: true }
  end
  
  def external_account_deauthorized
    if acct_id_from_webhook.present?
      int_stripe_acct = StripeAccount.unscoped.find_by(acct_id: acct_id_from_webhook)
      int_stripe_acct.update!(deleted: 1) if int_stripe_acct.present?
    end
    return render json: { success: true }
  end
  
  def external_account_updated
    #do nothing
    return render json: { success: true }
  end
  
  def deferred_account_activation
    int_stripe_acct = StripeAccount.unscoped.where(acct_id: params[:stripe_user_id]).first_or_create
    int_stripe_acct.update(deleted: 0)
    flash[:success] = "Your Stripe account has been activated!"
    redirect_to root_path
  end
  
  def regular_account_activation
    res = StripeAccountManager.get_access_token(params[:code])
    stripe_user = User.find_by_session_token(params[:state])
    
    if res["error_description"].present?
      flash[:error] = res["error_description"]
      return redirect_to root_path
    else
      stripe_account = StripeAccount.unscoped.where(acct_id: res["stripe_user_id"]).first_or_initialize
      if stripe_account.update(user_id: (stripe_user.try(:id) || -1), deleted: 0, access_token: res["access_token"], refresh_token: res["refresh_token"], publishable_key: res["stripe_publishable_key"])
        return on_successfull_stripe_activation(stripe_user)
      else
        flash[:error] = stripe_account.errors.full_messages.first
        return redirect_to root_path
      end
    end
  end
  
  protected
  
  def on_successfull_stripe_activation(stripe_user)
    if stripe_user.try(:full_member?)
      num_invoices = stripe_user.send_unsent_invoices
      if num_invoices > 0
        flash[:success] = "Your Stripe account has been connected.  We have sent out #{num_invoices} invoice#{"s" if num_invoices > 1}."
      else
        flash_stripe_connect_success
      end
      return redirect_to "/dashboard"
    elsif stripe_user.try(:assistant?)
      flash_stripe_connect_success
      return redirect_to "/clients"
    else
      flash_stripe_connect_success
      return redirect_to "/dashboard"
    end
  end
  
  def acct_id_from_webhook
    params["account"].presence
  end
  
  def record_stripe_webhook_event
    StripeWebhookEvent.create(event_type: params['type'], data: params["data"].to_json, account: params['account'])
  end
  
  def flash_stripe_connect_success
    flash[:success] = "You have connected your Stripe account to our platform.  You can now receive payments with your Stripe account"
  end

end
