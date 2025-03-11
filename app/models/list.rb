class List < ApplicationRecord
  
  include ActionView::Helpers::NumberHelper
  
  enum status: { "active" => 1, "inactive" => 0 }
  validate :valid_platform
  validate :valid_prices
  validate :has_pen_name_if_active
  validate :has_access_to_pen_name
  validate :not_deactivating_with_activity
  validate :list_found_in_api_results
  
  # validates_presence_of :api_key_id
  
  validate :valid_cutoff_date
  
  belongs_to :user
  has_many :inventories, dependent: :destroy
  has_many :one_day_inventories, dependent: :destroy
  
  has_many :reservations
  has_many :reservations_today, -> { accepted.where(date: Date.today_in_local_timezone) }, class_name: Reservation, foreign_key: :list_id
  has_many :recent_reservations, -> { accepted.where("reservations.date between ? and ?", Date.today_in_local_timezone - 5.days, Date.today_in_local_timezone - 2.day) }, class_name: Reservation, foreign_key: :list_id
  has_many :reservations_pending, -> { pending.order(date: :asc) }, class_name: Reservation, foreign_key: :list_id
  has_many :reservations_unconcluded, -> { accepted.unconfirmed.in_last_months(6) }, class_name: Reservation, foreign_key: :list_id
  
  has_many :external_reservations
  has_many :external_reservations_today, -> { where(date: Date.today_in_local_timezone) }, class_name: ExternalReservation, foreign_key: :list_id
  has_many :recent_external_reservations, -> { where("external_reservations.date between ? and ?", Date.today_in_local_timezone - 5.days, Date.today_in_local_timezone - 2.day) }, class_name: ExternalReservation, foreign_key: :list_id
  
  has_many :campaigns
  
  has_many :reservations_for_send_confirmation, -> { accepted.campaigns_fetched }, class_name: Reservation, foreign_key: :list_id
  has_many :external_reservations_for_send_confirmation, -> { campaigns_fetched }, class_name: ExternalReservation, foreign_key: :list_id
  
  has_many :lists_genres
  has_many :genres, through: :lists_genres
  
  belongs_to :pen_name, -> { unscope(where: :deleted) }
  belongs_to :api_key
  
  has_many :payments, through: :reservations, source: :connect_payments

  before_save :ensure_last_action_at
  before_save :clear_adopted_pen_name, unless: :pen_name_id?
  
  after_commit :generate_adopted_pen_names, if: Proc.new { |list| list.previous_changes.include?("pen_name_id") }
  
  PLATFORMS.each do |pform|
    define_method("#{pform}?") do 
      self.platform == pform
    end
  end

  def valid_platform
    unless PLATFORMS.include?(platform)
      errors.add(:platform, " is unknown")
    end
  end
  
  def has_pen_name_if_active
    if active? && pen_name.blank?
      errors.add(:base, "A pen name or promo service must be selected for all active lists")
    end
  end
  
  def has_access_to_pen_name
    if pen_name.present? && !pen_name.users_ids.include?(self.user_id)
      errors.add(:base, "You do not have access to use this pen name")
    end
  end

  def not_deactivating_with_activity
    if status_was == "active" && status == "inactive" && reservations_unconcluded.count > 0
      errors.add(:base, "You cannot deactivate a list with active or unconcluded bookings.")
    end
  end
  
  def list_found_in_api_results
    if status_changed? && active? && not_found_recently_in_api?
      errors.add(:base, "We cannot show this list in the marketplace. List not found in #{self.Platform} Api.  Please confirm your Api Integration is active.")
    end
  end
  
  def valid_cutoff_date
    if cutoff_date_changed? && self.cutoff_date.present?
      if cutoff_date < Date.today_in_local_timezone
        errors.add(:base, "Date must be in the future")
      elsif cutoff_date > 18.months.from_now
        errors.add(:base, "Date must be within 18 months from now")
      end
    end
  end
  
  def self.refresh_completed_recently?
    PLATFORMS.all? do |pform|
      List.where(platform: pform).maximum(:last_refreshed_at) > Time.now - 24.hours
    end
  end
  
  def Platform
    case platform
    when "mailchimp"
      "MailChimp"
    when "aweber"
      "AWeber"
    when "mailerlite"
      "MailerLite"
    when "convertkit"
      "ConvertKit"
    end
  end
  
  def active_member_count_delimited
    if active_member_count.present?
      number_with_delimiter(active_member_count)
    end
  end
  
  def open_rate_percent
    if open_rate.present? && open_rate > 0.0
      ((open_rate*1000).round/10.0).to_s + '%'
    end
  end
  
  def click_rate_percent
    if click_rate.present? && click_rate > 0.0
      ((click_rate*1000).round/10.0).to_s + '%'
    end
  end

  def api
    api_key.try(:init_api)
  end
  
  def not_found_recently_in_api?
    self.last_refreshed_at && self.last_refreshed_at < 1.week.ago
  end

  def has_confirmed_bookings?(date)
    self.reservations.accepted.where(date: date).exists? || self.external_reservations.where(date: date).exists?
  end

  def auto_handle_one_day_inventory!(date)
    raise "Cannot call #auto_handle_one_day_inventory without a date: #{date}" if !date
    if self.has_confirmed_bookings?(date)
      one_day_inventory = one_day_inventories.where(date: date).first_or_initialize
      one_day_inventory.mirror_weekly(self.inventories) unless one_day_inventory.persisted?
      one_day_inventory.save
    else
      self.one_day_inventories.automatic.where(date: date).destroy_all
    end
  end

  def subscribe(email_address, first_name = nil, last_name = nil)
    if !Email.valid?(email_address)
      return OpenStruct.new(success: false, message: 'Invalid email')
    elsif api.blank?
      return OpenStruct.new(success: false, message: 'Could not find/initialize api')
    else
      if self.mailchimp?
        res = api.subscribe_to_list(self.platform_id, email_address, first_name, last_name)
        if res.code.between?(200, 209)
          return OpenStruct.new(success: true)
        else
          return OpenStruct.new(success: false, message: JSON.parse(res.body)["detail"])
        end
      elsif self.aweber?
        begin
          res = api.subscribe_to_list(self.platform_id, email_address)
          if res.is_a?(AWeber::Resources::Subscriber)
            return OpenStruct.new(success: true)
          else
            return OpenStruct.new(success: false, message: JSON.parse(res.body)["error"]["message"])
          end
        rescue Exception, StandardError => e
          return OpenStruct.new(success: false, message: e.message)
        end
      elsif self.mailerlite?
        res = api.subscribe_to_list(self.platform_id, email_address)
        if res.code.between?(200, 209)
          return OpenStruct.new(success: true)
        else
          return OpenStruct.new(success: false, message: JSON.parse(res.body)["error"]["message"])
        end
      elsif self.convertkit?
        res = api.subscribe_to_form(self.platform_id, email_address)
        if res.code.between?(200, 209)
          return OpenStruct.new(success: true)
        else
          OpenStruct.new(success: false, message: JSON.parse(res.body)["message"])
        end
      end
    end
  end

  def unsubscribe(email_address)
    if !Email.valid?(email_address)
      return OpenStruct.new(success: false, message: 'Invalid email')
    elsif api.blank?
      return OpenStruct.new(success: false, message: 'Could not find api key')
    else
      if self.mailchimp?
        res = api.unsubscribe_from_list(self.platform_id, email_address)
        if res.code.between?(200, 209)
          return OpenStruct.new(success: true)
        else
          return OpenStruct.new(success: false, message: JSON.parse(res.body)["detail"])
        end
      elsif self.aweber?
        begin
          res = api.unsubscribe_from_list(self.platform_id, email_address)
          if res.code.to_i.between?(200,209)
            return OpenStruct.new(success: true)
          else
            return OpenStruct.new(success: false, message: JSON.parse(res.body)["error"]["message"])
          end
        rescue => e
          return OpenStruct.new(success: false, message: e.message)
        end
      elsif self.mailerlite?
        res = api.unsubscribe_from_list(self.platform_id, email_address)
        if res.code.between?(200, 209)
          return OpenStruct.new(success: true)
        else
          return OpenStruct.new(success: false, message: JSON.parse(res.body)["error"]["message"])
        end
      elsif self.convertkit?
        res = api.unsubscribe_from_form(self.platform_id, email_address)
        if res.code.between?(200, 209)
          return OpenStruct.new(success: true)
        else
          OpenStruct.new(success: false, message: JSON.parse(res.body)["status"])
        end
      end
    end
  end

  def retrieve_email_campaigns
    raise "Could not find/initialize api for list #{id} in List#retrieve_email_campaigns" unless self.api.present?
    
    result = []
    campaigns_data = api.retrieve_email_campaigns(self.platform_id)
    campaigns_data.each do |camp_attrs|
      campaign = self.campaigns.where(platform_id: camp_attrs[:platform_id]).first_or_initialize
      campaign.attributes = camp_attrs
      campaign.save!
      result << campaign
    end
    result
  end

  def valid_prices
    if solo_price.to_i < 0 || feature_price.to_i < 0 || mention_price.to_i < 0
      errors.add(:price, " is invalid")
    end
  end
  
  def price_of(inventory_type)
    self[inventory_type + "_price"]
  end
  
  def is_swap_only?(inventory_type)
    self.send("#{inventory_type}_is_swap_only?")
  end
  
  def price_text(inventory_type)
    if is_swap_only?(inventory_type)
      "Swap Only"
    elsif price_of(inventory_type).present?
      "$#{price_of(inventory_type)}"
    else
      "price not listed"
    end
  end
  
  def inventories_scaffolded
    {
      solo: inventories.solo.first_or_initialize,
      mention: inventories.mention.first_or_initialize,
      feature: inventories.feature.first_or_initialize
    }
  end
  

  def inv_types
    inventories.select(&:has_nonzero_day?).map(&:inv_type).uniq
  end
  
  def self.marketplace_search_clause(query)
    raise "illegal query: #{query}" if /delete|update|replace|insert/.match(query.downcase)
    raise "illegal query: #{query}" if /\;/.match(query.downcase)
    query = query.split('').map { |char| char == "'" ? "\\\'" : char }.join

    <<-SQL
      ( 
        lists.adopted_pen_name LIKE '%#{query}%' 
          OR
        genres.genre LIKE '%#{query}%'
      )
    SQL
  end

  def self.marketplace_base_query(*joins)
    List.distinct
    .references(*joins)
    .includes(*joins)
    .active
  end
  
  def self.marketplace_search(search_text)
    if search_text.match(/\"(.+)\"/)
      return marketplace_search_clause(search_text.match(/\"(.*)\"/)[1])
    end
    tokens = search_text.split(" ")
    queries = []
    for token in tokens
      queries << marketplace_search_clause(token)
    end
    queries.join(" OR ")
  end

  def ensure_last_action_at
    if !last_action_at?
      self.last_action_at = Time.now
    end
  end
  
  def author_profile_link_if_verified
    if pen_name.try(:verified?)
      pen_name.author_profile_url
    end
  end
  
  def generate_adopted_pen_names
    pen_name_ids = (self.previous_changes["pen_name_id"] || [self.pen_name_id]).compact
    PenName.generate_adopted_pen_names_for_lists(pen_name_ids)
  end
  
  def clear_adopted_pen_name
    self.adopted_pen_name = nil
  end
  
  def total_dollars_paid
    payments.select { |payment| !payment.refunded? }.map(&:amount).compact.sum/100
  end
  
  def campaigns_last_5
    @campaigns_last_5 ||= campaigns.order(sent_on: :desc).limit(5)
  end
    
end
