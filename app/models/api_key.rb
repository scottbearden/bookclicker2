class ApiKey < ApplicationRecord
  
  validates :account_id, :uniqueness => {:scope => :platform}, allow_nil: true
  
  validate :key_or_token

  include StatusEnum

  PLATFORMS.each do |pform|
    scope pform.to_sym, -> { where(platform: pform) }
    define_method("#{pform}?") do 
      self.platform == pform
    end
  end
  
  attr_encrypted :key, key: Digest::MD5.hexdigest(Rails.application.secret_key_base)
  attr_encrypted :token, key: Digest::MD5.hexdigest(Rails.application.secret_key_base)
  attr_encrypted :secret, key: Digest::MD5.hexdigest(Rails.application.secret_key_base)

  validate :valid_platform
  validate :not_duplicate
  
  belongs_to :user
  has_many :lists
  
  after_commit :update_mailing_lists, on: [:create, :update]
  before_destroy :deactivate_mailing_lists
  
  def update_mailing_lists
    MailingListsUpdatorJob.perform_async('perform_for_single_api_key', self.id, true)
  end
  
  def deactivate_mailing_lists
    self.lists.update_all(status: ApiKey.statuses[:inactive])
  end
  
  def key_or_token
    if key.blank? && token.blank?
      errors.add(:base, "Api credentials are invalid")
    end
  end
  
  def not_duplicate
    has_dupe = user.present? && user.api_keys.where(platform: self.platform).any? do |api_key|
      api_key.id != self.id &&
      ((self.key.present? && api_key.key == self.key) || (self.token.present? && api_key.token == self.token))  
    end
    if has_dupe
      errors.add(:base, "This is a duplicate key")
    end
  end
  
  def valid_platform
    unless PLATFORMS.include?(platform)
      errors.add(:platform, " is unknown")
    end
  end
  
  def init_api
    MailingPlatformApiFactory.init_api(self)
  end
  
  def platform_nice
    case platform
    when "mailchimp"
      "MailChimp"
    when "mailerlite"
      "MailerLite"
    when "convertkit"
      "ConvertKit"
    when "aweber"
      "AWeber"
    end
  end
  
  def update_api_dc!
    if mailchimp?
      self.api_dc = init_api.get_metadata["dc"]
      self.save
    end
  end
  
  def affected_lists
    @affected_lists ||= begin
      result = self.lists.includes(reservations_unconcluded: [{book: :pen_name}, {swap_reservation: :promo_send_confirmation}, :connect_payments, :promo_send_confirmation])
      result.select do |list| 
        list.reservations_unconcluded.any? do |res|
          res.cancellable_unpaid_promo? || res.last_minute_refundable? || res.last_minute_cancellable_swap? || res.swap_where_only_this_side_is_outstanding?
        end
      end
    end
  end
  
end
