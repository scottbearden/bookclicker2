class StripeAccountManager
  
  COUNTRY_CODES = ["US", "CA"]
  
  OAUTH_PATH = "https://connect.stripe.com/oauth/"
  
  def self.connect_account_url(user)
    OAUTH_PATH + "authorize?response_type=code&client_id=#{Figaro.env.stripe_client_id}&scope=read_write&state=#{user.session_token}"
  end
  
  def self.create_shared_customer_with_default_source(user, stripe_customer)
    bc_customer = StripeSharedCustomer.create!(
      user_id: user.id,
      customer_id: stripe_customer.id,
      email_address: stripe_customer.email
    )
    payment_method = Stripe::PaymentMethod.list({customer: stripe_customer.id, type: 'card'}).first
    create_default_source(bc_customer, stripe_customer, payment_method.id, payment_method.card, payment_method.billing_details)
  end
  
  def self.create_default_source(bc_customer, stripe_customer, payment_method_id, stripe_card, billing_details)
    #db call, not stripe api call
    default_source = bc_customer.sources.create!(
      card_id: payment_method_id,
      last4: stripe_card.last4,
      exp_month: stripe_card.exp_month,
      exp_year: stripe_card.exp_year,
      brand: stripe_card.brand,
      funding: stripe_card.funding,
      country: stripe_card.country,
      name: billing_details.name,
      address_line1: billing_details.address.line1,
      address_line2: billing_details.address.line2,
      address_city: billing_details.address.city,
      address_state: billing_details.address.state,
      address_zip: billing_details.address.postal_code,
      address_country: billing_details.address.country,
      cvc_check: stripe_card.checks.cvc_check,
      address_zip_check: stripe_card.checks.address_postal_code_check,
    )
    bc_customer.set_default_source(default_source, stripe_customer)
    default_source
  end
  
  def self.create_deferred_account(user)
    return nil unless user.country.present?
    
    ext_stripe_acct = Stripe::Account.create(
      :country => user.country,
      :managed => false,
      :email => user.email
    )
    int_stripe_acct = StripeAccount.where(acct_id: ext_stripe_acct["id"]).first_or_initialize
    int_stripe_acct.update!({
      user_id: user.id,
      deferred_acct_email: user.email,
      country: user.country,
      deleted: 0,
      publishable_key: ext_stripe_acct["keys"]["publishable"]
    })
    int_stripe_acct
  rescue Stripe::InvalidRequestError, Stripe::PermissionError => e
    nil
  end
  
  def self.deferred_account_activation_link(acct_id)
    "https://dashboard.stripe.com/account/activate?client_id=#{Figaro.env.stripe_client_id}&user_id=#{acct_id}"
  end
  
  def self.get_access_token(code)
    options = {
      body: {
        grant_type: "authorization_code",
        code: code,
        client_secret: Figaro.env.stripe_secret_key
      }
    }
    HTTParty.post(OAUTH_PATH + "token", options)
  end
  
  def self.create_customer(stripe_token, payer, receiver_stripe_account, description)
    stripe_customer = Stripe::Customer.create({
      :description => description,
      :source => stripe_token
    }, :stripe_account => receiver_stripe_account.acct_id)
    if stripe_customer["failure_message"].present?
      OpenStruct.new(success: false, failure_message: stripe_customer["failure_message"])
    else
      customer = StripeCustomer.create({
        user_id: payer.id,
        destination_stripe_account_id: receiver_stripe_account.id,
        default_source: stripe_customer["default_source"],
        cus_id: stripe_customer["id"],
        currency: stripe_customer["currency"],
        email: stripe_customer["email"]
      })
      OpenStruct.new(success: true, customer: customer)
    end
  end
  
end
