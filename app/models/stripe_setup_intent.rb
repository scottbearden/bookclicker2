class StripeSetupIntent < ApplicationRecord

  include StripeIntentConcern

  belongs_to :user
  validates :user, :intent_id, :status, presence: true

  def self.sync_with_api(stripe_object)
    stripe_setup_intent = StripeSetupIntent.find_by!(intent_id: stripe_object.id)
    stripe_setup_intent.update!(status: stripe_object.status)
    stripe_setup_intent
  end

  def self.create_for_user(user)
    setup_intent = Stripe::SetupIntent.create(
      customer: user.bc_customer.try(:customer_id),
      usage: "off_session",
    )
    user.stripe_setup_intents.create!(
      customer_id: setup_intent.customer,
      intent_id: setup_intent.id,
      status: setup_intent.status,
      usage: setup_intent.usage,
    )
    setup_intent
  end

end
