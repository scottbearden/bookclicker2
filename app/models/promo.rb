class Promo < ApplicationRecord
  
  belongs_to :book
  
  enum promo_type: { "feature" => "feature", "mention" => "mention", "solo" => "solo" }
  
  validates_presence_of :book, :date, :list_size, :uuid
  
  after_initialize :ensure_uuid
  
  def list_size=(val)
    if val.is_a?(String)
      val.gsub!(",","")
    end
    super(val)
  end
  
  def name=(val)
    if val.blank?
      val = nil
    end
    super(val)
  end
  
  def promo_type=(val)
    if val.blank?
      val = nil
    end
    super(val)
  end
  
  def ensure_uuid
    self.uuid ||= SecureRandom.hex
  end
  
  def unspecified?
    !promo_type?
  end
  
end