class Api::ReservationsController < Api::BaseController

  before_filter :require_current_member_user
  before_filter :ensure_reservation_is_pending_decision, only: [:accept, :decline]

  def accept
    if @reservation.update(seller_accepted_at: Time.now, reply_message: params['reply_message'])
      @reservation.list.update(last_action_at: Time.now)
      if @reservation.zero_dollar_offer?
        ListSubscription.handle_paid_reservation(@reservation)
        accept_or_decline_flash_info = "You have successfully accepted this booking.  The offer price is $0 and this booking is considered paid"
      elsif @reservation.seller_stripe_account.present?
        if @reservation.default_payment_source.present?
          stripe_payment_intent, stripe_pi_object = StripePaymentIntent.create_from_reservation(reservation, @reservation.default_payment_source.card_id, false)
          if stripe_payment_intent.succeeded?
            accept_or_decline_flash_info = "Booking accepted.  The buyer has been successfully charged.  This payment will appear in your Stripe Account"
          else
            accept_or_decline_flash_info = "Booking accepted.  Payment intent did not succeed and returned a status of '#{stripe_payment_intent.status}'.  An invoice has been sent to the buyer."
          end
        else
          accept_or_decline_flash_info = "Booking accepted.  Buyer does not have a payment method set up.  An invoice has been sent to the buyer."
        end
      else
        accept_or_decline_flash_info = "You have successfully accepted this booking. You must connect with stripe in order to invoice the buyer"
        @stripe_directive = {
          link: StripeAccountManager.connect_account_url(current_member_user),
          message: "Connect with stripe in order to invoice the buyer"
        }
      end
      HandleSellerReservationAcceptJob.delay.perform(@reservation.id)

      render json: {
        message: accept_or_decline_flash_info,
        stripe_directive: @stripe_directive,
        reservation: @reservation.as_json(methods: Reservation::INFO_JSON_METHODS)
      }, status: :ok
    else
      render json: {
        message: @reservation.errors.full_messages.first,
        reservation: @reservation.as_json(methods: Reservation::INFO_JSON_METHODS)
      }, status: :bad_request
    end
  end

  def decline
    @reservation.update!(seller_declined_at: Time.now, reply_message: params['reply_message'])
    accept_or_decline_flash_info = "You have declined this request"
    HandleSellerReservationDeclineJob.delay.perform(@reservation.id)
    if !@reservation.seller_stripe_account.present?
      @stripe_directive = {
        link: StripeAccountManager.connect_account_url(current_member_user),
        message: "In order to send invoices to buyers and receive payments in the future, you will need to connect a Stripe account.  You can use the link above."
      }
    end
    render json: {
      message: accept_or_decline_flash_info,
      stripe_directive: @stripe_directive,
      reservation: @reservation.as_json(methods: Reservation::INFO_JSON_METHODS)
    }, status: :ok
  end

  def dismiss
    if params[:sent_feed].present?
      @dismiss_timestamp_column = :dismissed_from_buyer_sent_feed_at
    else
      @dismiss_timestamp_column = :dismissed_from_buyer_activity_feed_at
    end

    if reservation.blank?
      render_404
    else
      reservation.update_column(@dismiss_timestamp_column, Time.now)
      return render json: { success: true }
    end
  end

  def confirmation_request
    if reservation.blank?
      render_404
    elsif reservation.buyer_can_request_confirmation?
      reservation.update_column(:confirmation_requested_at, Time.now)
      ConfirmationRequestJob.delay.perform(reservation.id)
      return render json: {
        success: true,
        reservation: reservation.as_json(
                       methods: Reservation::METHODS_FOR_BUYER_ACTIVITY)
        }, status: :ok
    else
      return render json: { success: false, message: 'Requesting confirmation for this booking is not allowed' }, status: :bad_request
    end
  end

  def refund_request
    if reservation.blank?
      render_404
    elsif reservation.buyer_can_request_refund?
      reservation.update_column(:refund_requested_at, Time.now)
      RefundRequestJob.delay.perform(reservation.id)
      return render json: {
        success: true,
        reservation: reservation.as_json(
                       methods: Reservation::METHODS_FOR_BUYER_ACTIVITY)
        }, status: :ok
    else
      return render json: { success: false, message: 'This action is not yet available.  It will be available soon' }, status: :bad_request
    end
  end
  
  def buyer_cancel
    @reservation = current_member_user.reservations_as_buyer.find_by_id(params[:id])
    if @reservation.nil?
      return render_404
    elsif @reservation.last_minute_cancellable_swap? || @reservation.swap_where_only_this_side_is_outstanding?
      @reservation.cancel_swap_as_buyer!
      return render json: { success: true }, status: :ok
    elsif @reservation.cancellable_unpaid_promo?
      @reservation.update(buyer_cancelled_at: Time.now)
      HandleCancelJob.delay.perform(@reservation.id)
      return render json: { success: true }, status: :ok
    else
      return render_422
    end
  end
  
  def seller_cancel
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    if @reservation.nil?
      return render_404
    elsif @reservation.last_minute_cancellable_swap?
      @reservation.cancel_swap_as_seller!(nil)
      return render json: { success: true }, status: :ok
    elsif @reservation.cancellable_unpaid_promo?
      @reservation.update(seller_cancelled_at: Time.now)
      HandleCancelJob.delay.perform(@reservation.id)
      return render json: { success: true }, status: :ok
    else
      return render_422
    end
  end
  
  def seller_cancel_all
    @reservations = current_member_user
                    .reservations_as_seller
                    .where(id: params[:reservation_ids])
                    .includes({book: :pen_name}, {swap_reservation: :promo_send_confirmation}, :connect_payments, :promo_send_confirmation)
              
              
    cancelled_ids = []
    @reservations.each do |res|
      if res.last_minute_cancellable_swap?
        res.cancel_swap_as_seller!(nil)
        cancelled_ids << res.id
      elsif res.cancellable_unpaid_promo?
        res.update(seller_cancelled_at: Time.now)
        HandleCancelJob.delay.perform(res.id)
        cancelled_ids << res.id
      end
    end

    return render json: {
      reservation_ids: cancelled_ids
    }, status: :ok
  end
  
  def buyer_cancel_all
    @reservations = current_member_user
                    .reservations_as_buyer
                    .where(id: params[:reservation_ids])
                    .includes({book: :pen_name}, {swap_reservation: :promo_send_confirmation}, :connect_payments, :promo_send_confirmation)
           
    cancelled_ids = []
    @reservations.each do |res|
      if res.last_minute_cancellable_swap? || res.swap_where_only_this_side_is_outstanding?
        res.cancel_swap_as_buyer!
        cancelled_ids << res.id
      elsif res.cancellable_unpaid_promo?
        res.update(buyer_cancelled_at: Time.now)
        HandleCancelJob.delay.perform(res.id)
        cancelled_ids << res.id
      end
    end
                    
    return render json: {
      reservation_ids: cancelled_ids
    }, status: :ok
  end
  
  def seller_refund
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    return render_404 if @reservation.nil?
    return render_422 if !@reservation.last_minute_refundable?
    
    ref_payment = @reservation.refundable_payment
    res = PaymentProcessor.refund(ref_payment)
    if res.success
      return render json: { success: true }, status: :ok
    else
      return render json: { success: false, error: res.failure_message }, status: :bad_request
    end
  end
  
  def buyer_refund
    @reservation = current_member_user.reservations_as_buyer.find_by_id(params[:id])
    return render_404 if @reservation.nil?
    return render_422 if !@reservation.last_minute_refundable?
    
    ref_payment = @reservation.refundable_payment
    res = PaymentProcessor.refund(ref_payment)
    if res.success
      return render json: { success: true }, status: :ok
    else
      return render json: { success: false, error: res.failure_message }, status: :bad_request
    end
  end

  private

  def ensure_reservation_is_pending_decision
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    if !@reservation.present?
      return render_404
    end
    if !@reservation.pending?
      return render json: {
        success: false,
        message: "This reservation has already been #{@reservation.status}",
        reservation: @reservation.as_json(methods: Reservation::INFO_JSON_METHODS)
      }, status: :bad_request
    end
  end

  def reservation
    @reservation ||= current_member_user.reservations_as_buyer.find_by_id(params[:id])
  end

end
