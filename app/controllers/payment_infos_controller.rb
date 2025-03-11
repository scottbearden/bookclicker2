class PaymentInfosController < ApplicationController
  
  before_action :require_current_member_user
  before_action :block_assistant
  
  def index
    bc_customer = current_member_user.bc_customer
    begin
      @setup_intent = StripeSetupIntent.create_for_user(current_member_user) unless bc_customer&.max_sources_reached?
    rescue Stripe::InvalidRequestError => e
      flash[:error] = "Stripe error: #{e.message}"
    end
    @customer = bc_customer.as_json(include: :sources, methods: [:default_source])
    
    if current_member_user.stripe_account.present?
      @has_stripe_account = true 
    else
      @connect_with_stripe_link = StripeAccountManager.connect_account_url(current_member_user)
    end
  end

  def create
    stripe_si_object = Stripe::SetupIntent.retrieve(params[:setup_intent_id])
    stripe_setup_intent = StripeSetupIntent.sync_with_api(stripe_si_object)

    if !stripe_setup_intent.succeeded?
      flash[:error] = report_stripe_unexpected_action_error(stripe_si_object)
      return redirect_to payment_infos_path
    end

    stripe_customer = nil
    bc_customer = current_member_user.bc_customer
    if bc_customer.present?
      begin
        stripe_customer = Stripe::Customer.retrieve(bc_customer.customer_id)
      rescue Stripe::InvalidRequestError, Stripe::PermissionError => e
        #we tried to retrieve the stripe customer and if this failed we just delete it
        bc_customer.set_deleted
        stripe_customer = bc_customer = nil
      end
    end
    if stripe_customer.present?
      payment_method = Stripe::PaymentMethod.attach(params[:payment_method], { customer: stripe_customer.id })
      StripeAccountManager.create_default_source(bc_customer, stripe_customer, payment_method.id, payment_method.card, payment_method.billing_details)
    else
      stripe_customer = Stripe::Customer.create({ payment_method: params[:payment_method] })
      StripeAccountManager.create_shared_customer_with_default_source(current_member_user, stripe_customer)
    end
    flash[:success] = "You've successfully added a card"
    return redirect_to payment_infos_path
  rescue Stripe::CardError => e
    PaymentProcessor.record_card_error(e, params[:payment_method], nil)
    flash[:error] = e.message
    return redirect_to payment_infos_path
  end

  def update
    bc_customer = current_member_user.bc_customer
    payment_source = bc_customer.sources.find_by_id(params[:id])
    raise "Card #{params[:id]} not found" unless payment_source.present?
    stripe_customer = Stripe::Customer.retrieve(bc_customer.customer_id)
    begin
      payment_method = Stripe::PaymentMethod.retrieve(payment_source.card_id)
    rescue => e
      payment_source.set_deleted
      flash[:error] = "Payment method could not be retrieved: #{e.message}.  Card ending in #{payment_source.last4} is being deleted."
      redirect_back(fallback_location: root_path)
    end
    payment_method.billing_details.name = payment_source.name = params[:name].presence
    payment_method.billing_details.address.line1 = payment_source.address_line1 = params[:address_line1].presence
    payment_method.billing_details.address.line2 = payment_source.address_line2 = params[:address_line2].presence
    payment_method.billing_details.address.city = payment_source.address_city = params[:address_city].presence
    payment_method.billing_details.address.state = payment_source.address_state = params[:address_state].presence
    payment_method.billing_details.address.postal_code = payment_source.address_zip = params[:address_zip].presence
    payment_method.billing_details.address.country = payment_source.address_country = params[:address_country].presence
    payment_method.save
    payment_source.cvc_check = payment_method.card.checks.cvc_check
    payment_source.address_zip_check = payment_method.card.checks.address_postal_code_check
    payment_source.save!
    flash[:success] = "Payment billing info updated"
  rescue => e
    flash[:error] = e.message
  ensure
    redirect_back(fallback_location: root_path)
  end
  
end
