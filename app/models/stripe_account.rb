class StripeAccount < ApplicationRecord
  
  belongs_to :user
  
  validates_presence_of :acct_id
  validates_uniqueness_of :acct_id

  scope :active, -> { where(deleted: 0) }
  default_scope  { active }
  
  
end