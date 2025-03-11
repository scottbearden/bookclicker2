class User < ApplicationRecord
  enum role: {
    "full_member" => 3,
    "admin" => 4,
    "assistant" => 5
  }
  
  acts_as_messageable  

  attr_accessor :conversation_pen_name
  
  has_secure_password
  
  validates_presence_of :role, message: "is invalid. Roles are #{roles.keys.join(", ")}"
  validates :email, :session_token, presence: true
  validates_uniqueness_of :email, case_sensitive: false

  validates_format_of :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates_format_of :auto_subscribe_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, allow_nil: true
  validates_format_of :first_name, :last_name, :email, with: /\A[^\<\>\\]+\z/ , allow_nil: true
  validates :password, length: { minimum: 6, allow_nil: true }  
  
  validates :country, length: { is: 2 }, allow_nil: true
  validate :unique_assistant_name
  
  has_many :pen_names #the pen names the user created first
  has_many :pen_name_requests, through: :pen_names
  
  has_many :list_ratings
  
  has_many :users_pen_names
  has_many :pen_names_used, through: :users_pen_names, source: :pen_name
  
  has_many :books, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  
  has_many :api_requests, dependent: :destroy
  has_many :emails
  has_many :user_events
  
  has_many :list_subscriptions
  has_many :list_subscriptions_lists, through: :list_subscriptions, source: :list
  
  has_many :reservations_as_seller, through: :lists, source: :reservations
  has_many :reservations_as_buyer, through: :books, source: :reservations

  has_many :recent_book_promos_feed, through: :books, source: :recent_reservations_feed
  
  has_many :external_reservations, through: :lists
  
  has_many :reservations_for_send_confirmation, through: :lists
  has_many :external_reservations_for_send_confirmation, through: :lists
  
  has_one :stripe_account
  has_one :stripe_customer #str
  has_one :stripe_shared_customer
  alias :bc_customer :stripe_shared_customer
  has_many :stripe_setup_intents
  
  has_many :password_tokens
  
  has_many :users_assistants
  has_many :assistants, through: :users_assistants, source: :assistant
  
  has_many :assistant_invites, foreign_key: :member_user_id
  
  has_many :assistants_users, class_name: 'UsersAssistant', foreign_key: :assistant_id
  has_many :assisted_users, through: :assistants_users, source: :user
  
  before_save :set_email_unverified, if: Proc.new { |u| !u.skip_email_verification && u.email_changed? }
  after_save :handle_email_changed, if: Proc.new { |u| !u.skip_email_verification && u.email_changed? }
  after_initialize :ensure_session_token

  attr_accessor :skip_email_verification, :auth_token
  accepts_nested_attributes_for :lists

  def accepted_tos?
    self.accepted_tos_at.present? && self.accepted_tos_at > TermsOfService.most_recent.created_at
  end
  
  def unique_assistant_name
    if self.assistant? && full_name.present? 
      if User.assistant.where(last_name: self.last_name, first_name: self.first_name).where.not(id: self.id).exists?
        errors.add(:base, "This assistant name is already taken.  If this name belongs to you, please send a message to disputes@bookclicker.com")
      end
    end
  end
    
  def last_assistant_invite
    assistant_invites.order(created_at: :desc).first
  end
  
  def self_with_assistants
    [self].concat(assistants)
  end
  
  def self.generate_session_token
    SecureRandom::urlsafe_base64(16)
  end
  
  def lists_last_refreshed_at
    lists.select("max(last_refreshed_at) d")[0].d
  end

  def email_verified?
    email_verified_at?
  end
  
  def verify_email_link
    SITE_URL + "/verify_email?ve_token=#{session_token}&digest=#{email_digest}"
  end

  def email_unless_banned
    self.email unless Email.banned?(self.email)
  end

  def email_digest
    Digest::MD5.hexdigest(self.email.downcase)
  end
  
  def verify_email!
    self.email_verified_at = Time.now
    self.save!
    EmailVerifiedJob.perform_async(self.id)
  end
  
  def default_book
    return @default_book if @default_book
    @default_book ||= books.joins(:reservations).order("reservations.created_at desc").first
    @default_book ||= books.order(updated_at: :desc).first
  end
  
  def reset_session_token!
    self.session_token = User.generate_session_token
    self.save!
    self.session_token
  end
  
  def ensure_session_token
    self.session_token ||= User.generate_session_token
  end
  
  def api_keys_scaffolded
    result = self.api_keys.order(:created_at).to_a
    for platform in PLATFORMS
      if result.none? { |api_key| api_key.platform == platform }
        result.push(ApiKey.new(user_id: id, platform: platform))
      end
    end
    result
  end
  
  def full_name
    result = (first_name || "")
    result += " " + (last_name || "")
    result.strip.presence
  end
  
  def name=(name)
    if name.present?
      name_parts = name.split(" ")
      self.first_name = name_parts.shift.presence
      self.last_name = name_parts.join(" ").presence
    end
  end
  
  def last_name_first
    if first_name.present? && last_name.present?
      last_name + ", " + first_name
    else
      full_name
    end
  end
  
  def name_fallback_email
    if full_name.present?
      "#{full_name}&nbsp;<span>[#{email}]</span>".html_safe
    else
      email
    end
  end
  
  def full_name_or_email
    full_name.presence || email
  end
  
  def send_unsent_invoices
    num_invoices_scheduled = 0
    reservations_as_seller.select(&:buyer_yet_to_be_invoiced?).each do |reservation|
      num_invoices_scheduled += 1
      InvoiceBuyerJob.perform_async(reservation.id)
    end
    num_invoices_scheduled
  end
  
  def email_for_auto_subscribe
    (self.auto_subscribe_email.presence || self.email).downcase
  end
  
  def reset_password_link
    SITE_URL + "/reset_password?token=#{self.generate_password_token}"
  end
  
  def upcoming_book_id
    books.first.try(:id)
  end
  
  def self.order_by_first_name_sql
    "CASE WHEN users.first_name IS NULL THEN 1 ELSE 0 END ASC, users.first_name asc"
  end
  
  def users_assistants_ordered_json
    users_assistants
    .joins(:assistant)
    .includes(:assistant, :assistant_payment_requests)
    .sort_by(&:ui_sort_score)
    .as_json(
       methods: [:payment_request_json],
       include: {
         assistant: { only: [:id], methods: [:full_name_or_email] }
       }
    )
  end
  
  def assisting_display_name
    pen_names_used[0].try(:author_name) || full_name.presence
  end
  
  def handle_email_changed
    previous_email = self.email_verified_at_was ? self.email_was : nil
    #we only care if the email was previously verified
    EmailVerificationJob.perform_async(self.id, previous_email)
  end
  
  def set_email_unverified
    self.email_verified_at = nil
  end
  
  def generate_password_token
    self.password_tokens.create.token
  end
  
  def destroy_assistant
    raise "Can only destroy assistant" if !assistant?
    assistants_users.includes(:assistant_payment_requests, :user).each do |u_to_a_record|
      u_to_a_record.assistant_payment_requests.each do |pay_request|
        pay_request.terminate_active_subscription if pay_request.can_terminate_subscription?
        pay_request.destroy unless pay_request.accepted? #dont destroy accepted pay requests 
      end
      
      member = u_to_a_record.user
      if member.present?
        NotifyMemberThatAssistantHasDeletedAccountJob.perform_async(member.id, self.full_name, self.email)
      end
      u_to_a_record.destroy
    end
    if self.email_verified?
      MailingSegmentManager.new.remove(self, self.email)
    end
    self.destroy
  end
  
  def prohibitive_refund_request_reservation
    @prohibitive_refund_request_reservation ||= reservations_as_seller.includes(:promo_send_confirmation, :connect_payments).where.not(refund_requested_at: nil).select(&:prohibitive_refund_request?).first || ""
  end
  
  def list_ratings_hash_by_list_id(list_ids: [])
    res = self.list_ratings.where(list_id: list_ids)
    results = {}
    res.each do |list_rating|
      results[list_rating.list_id] = list_rating.as_json
    end
    results
  end
  
  def close_member_account!
    raise "Can only close member accounts" unless self.full_member?
    api_keys.each(&:destroy)
    users_assistants.each(&:destroy)
    self.update!(closed_at: Time.now, bookings_subscribed: false, confirmations_subscribed: false)
  end
  
  def affected_books
    @affected_books ||= begin
      result = self.books.includes(reservations_unconcluded: [{book: :pen_name}, {swap_reservation: :promo_send_confirmation}, :connect_payments, :promo_send_confirmation])
      result.select do |book| 
        book.reservations_unconcluded.any? do |res|
          res.cancellable_unpaid_promo? || res.last_minute_refundable? || res.last_minute_cancellable_swap? || res.swap_where_only_this_side_is_outstanding?
        end
      end
    end
  end

  def unread_conversations_count
    self.mailbox.inbox(:read => false).count
  end
  
  #MAILBOXER METHODS
  def mailboxer_email(object)
    return nil
  end
  
end

