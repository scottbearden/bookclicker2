class StripeCustomer < ApplicationRecord
  
  belongs_to :user
  validates_presence_of :cus_id, :destination_stripe_account_id
  
  scope :active, -> { where(deleted: 0) }
  default_scope  { active }
  
end