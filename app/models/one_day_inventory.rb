class OneDayInventory < ApplicationRecord

  belongs_to :list
  enum source: { "automatic" => "automatic", "manual" => "manual" }

  scope :future, -> { where("date >= ?", Date.today_in_local_timezone)}

  validates_presence_of :date, :list_id, :source
  
  before_save :ensure_inventory!

  def mirror_weekly(weekly_inventories)
    day_of_week = self.date.day_of_week
    weekly_inventories.each do |inventory|
      self[inventory.inv_type] = inventory[day_of_week]
    end
  end
  
  
  def days_data(includes: [])
    raise "Must provide date" unless self.date.present?
    bookings = self.list.reservations.includes(includes).where(date: self.date)
    pending_system_bookings = bookings.select(&:pending?)
    accepted_system_bookings = bookings.select(&:accepted?)
    
    external_bookings = self.list.external_reservations.includes(:promo_send_confirmation).where(date: self.date)
    
    solos_remaining = self.solo.to_i - accepted_system_bookings.select(&:solo?).length - external_bookings.select(&:solo?).length
    features_remaining = self.feature.to_i - accepted_system_bookings.select(&:feature?).length - external_bookings.select(&:feature?).length
    mentions_remaining = self.mention.to_i - accepted_system_bookings.select(&:mention?).length - external_bookings.select(&:mention?).length
    
    OpenStruct.new(
      pending_system_bookings: pending_system_bookings,
      accepted_system_bookings: accepted_system_bookings,
      external_bookings: external_bookings,
      solos_remaining: solos_remaining,
      features_remaining: features_remaining,
      mentions_remaining: mentions_remaining
    )
  end
  
  def ensure_inventory!
    data = self.days_data
    if data.solos_remaining < 0
      self.solo = 1
    end
    if data.features_remaining < 0
      self.feature = 1
    end
    if data.mentions_remaining < 0
      self.mention = [ self.mention - data.mentions_remaining, 9 ].min
    end
  end

end
