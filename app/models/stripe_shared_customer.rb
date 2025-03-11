class StripeSharedCustomer < ApplicationRecord

  MAX_SOURCES_PER_CUSTOMER = 4
  
  belongs_to :user
  
  validates_presence_of :user_id, :customer_id
  
  scope :active, -> { where(deleted: 0) }
  default_scope  { active }
  
  has_many :stripe_shared_customer_sources
  
  alias :sources :stripe_shared_customer_sources

  def set_default_source(source, stripe_customer)
    stripe_customer.invoice_settings.default_payment_method = source.card_id
    stripe_customer.save
    ActiveRecord::Base.connection.execute(<<-SQL)
      UPDATE `stripe_shared_customer_sources` t
      SET t.`default` = if(card_id = '#{source.card_id}', 1, 0)
      WHERE t.stripe_shared_customer_id = #{id}
    SQL
  end
  
  def set_deleted
    self.deleted = 1
    self.save
  end

  def default_source
    sources.find_by(default: 1) || sources.order(updated_at: :desc).first
  end

  def max_sources_reached?
    sources.count > MAX_SOURCES_PER_CUSTOMER
  end
  
end
