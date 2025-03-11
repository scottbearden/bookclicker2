class Inventory < ApplicationRecord
  
  belongs_to :list
  
  enum inv_type: { "solo" => "solo", "feature" => "feature", "mention" => "mention" }
  
  validate :valid_inventory_type
  
  def valid_inventory_type
    unless Inventory.all_types.include?(self.inv_type)
      errors.add(:inv_type, 'is invalid')
    end
  end

  def self.all_types
    Inventory.inv_types.keys
  end
  
  def has_nonzero_day?
    monday.to_i > 0 || 
    tuesday.to_i > 0 || 
    wednesday.to_i > 0 || 
    thursday.to_i > 0 || 
    friday.to_i > 0 || 
    saturday.to_i > 0 || 
    sunday.to_i > 0
  end
  
end