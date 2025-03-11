class AssistantPaymentRequest < ApplicationRecord
  
  belongs_to :users_assistant
  has_one :payer_member, through: :users_assistant, source: :user
  has_one :assistant, through: :users_assistant, source: :assistant
  
  validates_presence_of :pay_amount, :users_assistant_id
  validate :pay_amount_okay
  validate :assistant_can_get_paid, on: :create #must be last validation
  
  after_create :notify_account_member_of_request
    
  def assistant_can_get_paid
    return nil if self.errors.messages.present?
    if !assistant.stripe_account.present?
      errors.add(:base, "You must first <a href='#{StripeAccountManager.connect_account_url(assistant)}' target='_blank'>connect with stripe</a> to receive payments")
    end
  end
  
  def pay_amount_okay
    if pay_amount.to_i < 1
      errors.add(:base, "Invalid pay amount")
    end
  end
  
  def unanswered?
    !accepted? && !declined?
  end
  
  def accepted?
    accepted_at?
  end
  
  def declined?
    !accepted_at? && declined_at?
  end
  
  def decline!
    self.update({declined_at: Time.now})
    HandlePaymentPlanDeclineJob.perform_async(self.id)
  end
  
  def cancelled?
    agreement_cancelled_at?
  end
  
  def ongoing?
    (accepted? && !cancelled?) || unanswered?
  end
  
  def status
    #tied to ui in ClientManager.jsx
    if unanswered?
      "unanswered"
    elsif cancelled?
      "cancelled"
    elsif accepted?
      "accepted"
    else
      "declined"
    end
  end
  
  def notify_account_member_of_request
    AssistantPaymentRequestJob.perform_async(self.id)
  end
  
  def self.empty_ui_json
    { pay_amount: nil, status: nil }
  end
  
  def as_ui_json
    as_json(methods: [:status, :unanswered?, :accepted?, :declined?, :ongoing?, :cancelled?])
  end
  
  def create_plan
    random_id = SecureRandom::urlsafe_base64(4)
    
    plan_name = "Weekly Plan #{self.id} #{random_id}"
    plan_id = "weekly-#{id}-#{random_id}"
    stripe_entity = Stripe::Plan.create({
      :name => plan_name,
      :id => plan_id,
      :interval => "week",
      :currency => "usd",
      :amount => pay_amount*100
    }, :stripe_account => assistant.stripe_account.acct_id)

    SubscriptionPlan.create({
      name: plan_name,
      stripe_acct_id: assistant.stripe_account.acct_id,
      stripe_plan_id: plan_id,
      interval: "week",
      currency: "usd",
      amount: pay_amount*100
    })
  end
  
  def created_at_pretty
    created_at.try(:to_date).try(:pretty)
  end
  
  def get_subscription_status!
    return nil if !accepted?
    return nil if !assistant.present?
    return nil if last_known_subscription_status == 'error' 
    
    subscription = Stripe::Subscription.retrieve(stripe_subscription_id, stripe_account: assistant_stripe_acct_id)
    
    if subscription["status"] == "canceled"
      self.update({
        agreement_cancelled_at: Time.now,
        last_known_subscription_status: subscription["status"],
        last_known_subscription_status_at: Time.now
      })
    else
      self.update({
        last_known_subscription_status: subscription["status"],
        last_known_subscription_status_at: Time.now
      })
    end
  rescue Stripe::InvalidRequestError, Stripe::PermissionError => e
    puts e.message
    self.update({
      last_known_subscription_status: 'error',
      last_known_subscription_status_at: Time.now
    })
  end
  
  def can_terminate_subscription?
    stripe_subscription_id.present? && assistant_stripe_acct_id.present? && !cancelled?
  end
  
  def terminate_active_subscription
    error = nil
    begin
      subscription = Stripe::Subscription.retrieve(stripe_subscription_id, stripe_account: assistant_stripe_acct_id)
      subscription.delete
    rescue Stripe::InvalidRequestError, Stripe::PermissionError => e
      if /No\ssuch\ssubscription\:\ssub/.match(e.message) 
        error = nil
      else
        error = e.message
      end
    ensure
      self.update_column(:agreement_cancelled_at, Time.now)
    end
    
    if error
      OpenStruct.new(success: false, failure_message: error)
    else
      OpenStruct.new(success: true)
    end
  end
  
  def assistant_stripe_acct_id
    users_assistant.try(:assistant).try(:stripe_account).try(:acct_id).to_s
  end
  
end