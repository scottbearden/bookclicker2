class StripeSharedCustomerSource < ApplicationRecord
  
  ALLOWED_CARD_UPDATE_ATTRIBUTES = ["name", "address_line1", "address_line2", "address_city", "address_state", "address_zip", "address_country"]
  
  belongs_to :stripe_shared_customer

  validates_presence_of :card_id
  
  scope :active, -> { where(deleted: 0) }
  scope :default, -> { where(default: 1) }
  default_scope  { active }
  
  def set_deleted
    self.deleted = 1
    self.save
  end
  
end
