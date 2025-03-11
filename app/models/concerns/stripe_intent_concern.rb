module StripeIntentConcern
  extend ActiveSupport::Concern
  
  included do
    validates_uniqueness_of :intent_id

    enum status: {
      "requires_payment_method" => "requires_payment_method",
      "requires_confirmation" => "requires_confirmation", # I dont use this one, it's optional
      "requires_action" => "requires_action",
      "processing" => "processing",
      "canceled" => "canceled",
      "succeeded" => "succeeded",
      "requires_source" => "requires_source",
      "requires_source_action" => "requires_source_action",
    }
  end

  def has_next_action?
    requires_action? || requires_source_action?
  end
end
