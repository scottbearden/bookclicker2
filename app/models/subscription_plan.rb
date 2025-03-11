class SubscriptionPlan < ApplicationRecord
  
  validates_presence_of :stripe_plan_id
  
  
  
end