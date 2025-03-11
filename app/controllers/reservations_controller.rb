class ReservationsController < ApplicationController
  before_action :restrict_booking_access, only: [:create, :swap]
  
  before_action :sign_in_via_auth_token_param, only: [:accept, :decline, :pay]
  before_action :ensure_reservation_is_pending_decision, only: [:accept, :decline]

  before_action :require_current_member_user
  
  def accept
    #just a gateway, lets me apply before_action
    redirect_to info_reservation_path(@reservation)
  end
  
  def decline
    #just a gateway, lets me apply before_action
    redirect_to info_reservation_path(@reservation)
  end
  
  def create
    reservation = Reservation.new(reservation_attributes)
    if reservation.payment_offer? && !reservation.zero_dollar_offer? && !current_member_user.bc_customer.try(:default_source).present?
      if current_assistant_user.present?
        flash[:error] = "The account owner must add a credit or debit card in order to request a paid booking.  This can be done on the account owner's Payment Info page."
        redirect_back(fallback_location: root_path) 
      else
        flash[:error] = "You must add a credit or debit card in order to request a paid booking"
        return redirect_to payment_infos_path
      end
    elsif reservation.save
      reservation.list.update(last_action_at: Time.now)
      HandleNewReservationJob.perform_async(reservation.id)
      flash[:success] = "Your request has been sent.  The seller has been notified.  We will notify you when the seller accepts or declines this booking."
      redirect_back(fallback_location: root_path)
    else
      flash[:error] = reservation.errors.full_messages.first
      redirect_back(fallback_location: root_path)
    end
  end
  
  def ensure_reservation_is_pending_decision
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    if !@reservation.present?
      return render_404
    end
    if !@reservation.pending?
      flash[:notice] = "This reservation has already been #{@reservation.status}"
      return redirect_to info_reservation_path(@reservation)
    end
  end

  def swap
    @first_reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    @reservation = Reservation.new(reservation_attributes)
    @reservation.swap_reservation_id = @first_reservation.id
    @reservation.seller_accepted_at = Time.now
    if @reservation.save
      @reservation.list.update(last_action_at: Time.now)
      @first_reservation.update!(seller_accepted_at: Time.now, swap_reservation_id: @reservation.id)
      @first_reservation.list.update(last_action_at: Time.now)
      
      HandleSellerReservationAcceptJob.perform_async(@first_reservation.id)
      ListSubscription.handle_paid_reservation(@first_reservation)
      ListSubscription.handle_paid_reservation(@reservation)
      
      flash[:success] = "You have completed the swap.  The other author has been notified and your promos have been saved."
      return redirect_to info_reservation_path(@reservation)
    else
      flash[:error] = @reservation.errors.full_messages.first
      redirect_back(fallback_location: root_path)
    end
  end
  
  def cancel_swap
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    if @reservation.blank? || !@reservation.cancellable_swap?
      return render_422
    end
    @reservation.cancel_swap_as_seller!(params[:seller_cancelled_reason])
    flash[:info] = "This swap has been cancelled and the other author has been notified"
    return redirect_to info_reservation_path(@reservation)
  end
  
  def cancel_swap_as_buyer
    @reservation = current_member_user.reservations_as_buyer.find_by_id(params[:id])
    if @reservation.blank? || !@reservation.cancellable_swap?
      return render_422
    end
    @reservation.cancel_swap_as_buyer!
    flash[:info] = "This swap has been cancelled and the other author has been notified"
    return redirect_to info_reservation_path(@reservation)
  end
  
  def cancel_unpaid_promo
    @reservation = current_member_user.reservations_as_buyer.find_by_id(params[:id])
    if @reservation.blank? || !@reservation.cancellable_unpaid_promo?
      return render_422
    end
    @reservation.update(buyer_cancelled_at: Time.now)
    HandleCancelJob.perform_async(@reservation.id)
    flash[:info] = "You have cancelled this booking and the seller has been notified"
    return redirect_to info_reservation_path(@reservation)
  end
  
  def request_cancel_and_refund
    @reservation = current_member_user.reservations_as_buyer.find_by_id(params[:id])
    
    if @reservation.blank? || !@reservation.buyer_can_request_cancel_and_refund?
      return render_422
    end
    
    @reservation.update_column(:refund_requested_at, Time.now)
    RefundRequestJob.perform_async(@reservation.id)
    flash[:info] = "Your refund request has been sent"
    redirect_back(fallback_location: root_path)
  end
  
  def info
    @reservation = current_member_user.reservations_as_buyer.find_by_id(params[:id]) || current_member_user.reservations_as_seller.find_by_id(params[:id])
    return render_404 unless @reservation.present?
    
    if current_member_user == @reservation.buyer && @reservation.awaiting_payment_and_seller_stripe_account_present?
      return redirect_to pay_reservation_path(@reservation)
    end
    
    if current_member_user == @reservation.seller
      if @reservation.awaiting_payment_and_seller_stripe_account_missing?
        @stripe_directive = {
          link: StripeAccountManager.connect_account_url(current_member_user),
          message: "In order to send invoices to buyers and receive payments in the future, you will need to connect a Stripe account.  You can use the link above."
        }
      elsif params['withRefundLink'].present?
        @refund_directive = {
          possible: @reservation.refundable_payment.present?,
          amount: @reservation.refundable_amount
        }
      elsif ["accepted", "declined", "pending"].include?(@reservation.status)
        @accept_decline_directive = true
      end
    end
    
    @just_buyer_side = params['jb'].present?
    @title = "Booking ##{@reservation.id}"
    pull_reservation_data
    render :page
  end
  
  def pay
    @reservation = current_member_user.reservations_as_buyer.find_by_id(params[:id])
    @just_buyer_side = true
    return render_404 unless @reservation.present?
    bc_customer = current_member_user.bc_customer

    if @reservation.awaiting_payment_and_seller_stripe_account_present?
      @title = 'Payments'
      @customer = bc_customer.as_json(include: :sources, methods: [:default_source])
      _, @payment_intent = StripePaymentIntent.create_from_reservation(@reservation, nil, true)

      if bc_customer&.default_source.present?
        @cloned_payment_method = Stripe::PaymentMethod.create({
          customer: bc_customer.customer_id,
          payment_method: bc_customer.default_source.card_id,
        }, {
          stripe_account: @reservation.seller_stripe_acct_id,
        }).id
      end
      @seller_stripe_acct_id = @reservation.seller_stripe_acct_id
      pull_reservation_data
      return render :page
    elsif @reservation.awaiting_payment_and_seller_stripe_account_missing?
      flash[:notice] = "The seller has not yet set up their Stripe account to receive payments.  Please check back soon."
      return redirect_to info_reservation_path(@reservation)
    else
      flash[:notice] = "This booking is #{@reservation.status} and is unavailable for payment"
      return redirect_to info_reservation_path(@reservation)
    end
  end
  
  def reschedule
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    return render_404 unless @reservation.present?
    if !@reservation.present? || !@reservation.accepted?
      flash[:error] = "This action is not allowed [Booking #{@reservation.id}]"
      redirect_back(fallback_location: root_path)
    end
    
    if reschedule_date.present?
      if reschedule_date == @reservation.date || reschedule_date <= Date.today_in_local_timezone
        flash[:error] = "Please select a different date [#{@reservation.id}]"
        redirect_back(fallback_location: root_path)
      else
        @reservation.date = reschedule_date
        @reservation.save!
        date_was = @reservation.previous_changes["date"].try(:first).try(:pretty)
        SellerRescheduleJob.perform_async(@reservation.id, date_was)
        flash[:success] = "This booking has been rescheduled to #{@reservation.date.pretty}"
        redirect_back(fallback_location: root_path)
      end
    else
      flash[:error] = "The date you submitted was not recognized"
      redirect_back(fallback_location: root_path)
    end
  end
  
  def refund
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:id])
    return render_404 unless @reservation.present?
    
    ref_payment = @reservation.refundable_payment
    if !ref_payment.present?
      flash[:error] = "Booking #{@reservation.id} cannot be refunded."
      redirect_back(fallback_location: root_path)
    else
      res = PaymentProcessor.refund(ref_payment)
      if res.success
        flash[:success] = "You have successfully refunded a payment of #{ref_payment.amount.to_i/100} #{ref_payment.currency.try(:upcase)}"
        redirect_to info_reservation_path(@reservation)
      else
        flash[:error] = "Refund failure: #{res.failure_message}"
        redirect_to info_reservation_path(@reservation)
      end
    end
  end
  
  private

  def swap_offer?
    params[:reservation][:swap_offer].to_i == 1
  end

  def swap_offer_list_id
    _id = params[:reservation][:swap_offer_list_id].to_i
    if current_member_user.lists.map(&:id).include?(_id)
      _id
    end
  end
  
  def reservation_attributes
    {
      book_id: @book.id,
      list_id: @list.id,
      message: params[:reservation][:message].presence,
      price: @list.price_of(params[:inv_type]),
      premium: params[:reservation][:premium],
      payment_offer: params[:reservation][:payment_offer].to_i,
      swap_offer: swap_offer?,
      swap_offer_list_id: swap_offer_list_id,
      swap_offer_solo: swap_offer? ? params[:reservation][:swap_offer_solo].to_i : nil,
      swap_offer_feature: swap_offer? ? params[:reservation][:swap_offer_feature].to_i : nil,
      swap_offer_mention: swap_offer? ? params[:reservation][:swap_offer_mention].to_i : nil,
      date: params[:date],
      inv_type: params[:inv_type]
    }
  end
  
  def pull_reservation_data
    @reservation.im_sending_this = (@reservation.seller == current_member_user) && !@just_buyer_side
    #dont show me as sender if im also the buyer and clicking in from a buyer side link
    @book = @reservation.book
    @list = @reservation.list
    @buyer = @reservation.buyer
    @confirmed_campaign = @reservation.get_confirmed_campaign
    pull_swap_reservation_data if @reservation.swap_reservation.present?
  end
  
  def pull_swap_reservation_data
    @swap_reservation = @reservation.swap_reservation
    @swap_reservation.im_sending_this = (@swap_reservation.seller == current_member_user)
    
    @swap_book = @swap_reservation.book
    @swap_list = @swap_reservation.list
    @swap_buyer = @swap_reservation.buyer
  end

  def restrict_booking_access
    if !book || !list
      flash[:error] = "This list is unavailable for booking"
      redirect_back(fallback_location: root_path)
    end
  end
  
  def book
    @book ||= current_member_user.books.find_by_id(params[:book_id])
  end
  
  def list
    @list ||= List.status_active.find_by_id(params[:list_id])
  end
  
  def reschedule_date
    Date.parse(params[:reservation][:date])
  rescue
    nil
  end
  
end
