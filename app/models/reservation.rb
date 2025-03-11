class Reservation < ApplicationRecord

  belongs_to :book, -> { unscope(where: :deleted) }
  belongs_to :list
  belongs_to :swap_offer_list, class_name: 'List', foreign_key: :swap_offer_list_id, optional: true
  belongs_to :swap_reservation, class_name: 'Reservation', foreign_key: :swap_reservation_id, optional: true
  has_one :buyer, through: :book, source: :user
  has_one :seller, through: :list, source: :user
  has_one :seller_stripe_account, through: :seller, source: :stripe_account

  scope :not_cancelled, -> { where(seller_cancelled_at: nil, system_cancelled_at: nil, buyer_cancelled_at: nil) }
  scope :not_refunded, -> { where("not exists (select 1 from connect_payments pmt_refunded where pmt_refunded.reservation_id = reservations.id and pmt_refunded.refunded = 1)") }

  scope :accepted, -> { where.not(seller_accepted_at: nil).not_cancelled.not_refunded }
  scope :pending, -> { not_cancelled.where(seller_accepted_at: nil, seller_declined_at: nil) }
  scope :accepted_or_pending, -> { accepted.or(pending) }
  scope :unconfirmed, -> { where("not exists (select 1 from promo_send_confirmations psc where psc.reservation_type = 'Reservation' and psc.reservation_id = reservations.id)") }

  has_one :promo_send_confirmation, -> { internal }
  include ConfirmationsConcern

  has_many :connect_payments
  has_many :connect_refunds, through: :connect_payments, source: :connect_refunds

  has_many :stripe_payment_intents

  validates_presence_of :book_id, :list_id, :date, :inv_type

  validate :has_payment_offer_or_swap_offer
  validate :valid_swap_offer
  validate :valid_payment_offer

  before_create :set_recorded_list_name
  after_commit :save_one_day_inventory

  attr_accessor :im_sending_this

  INFO_JSON_METHODS = [:declined?, :pending?, :send_confirmed?, :im_sending_this, :accepted?, :cancelled?, :status, :internal, :status_plus, :paid?, :date_pretty, :price_in_play?, :swap_in_play?, :payment_offer?, :swap_offer?, :payment_offer_accepted?, :swap_offer_accepted?, :payment_offer_total, :swap_offer_inv_types, :clazz]

  AS_JSON_FOR_CONFIRM_PROMO_OPTIONS = {
    methods: [:confirmed_campaign_id, :manual_campaign_preview_url].concat(Reservation::INFO_JSON_METHODS),
    include: {
      list: {
        only: [:adopted_pen_name],
        methods: [:active_member_count_delimited, :campaigns_last_5, :open_rate_percent, :click_rate_percent, :Platform]
      },
      book: {
        only: [:title, :cover_image_url], methods: [:author]
      },
      buyer: {
        only: [:email]
      },
      confirmed_campaign: {
        methods: []
      }
    }
  }

  METHODS_FOR_BUYER_ACTIVITY = [
      :status,
      :created_at_pretty,
      :cancelled_reason,
      :awaiting_payment?,
      :awaiting_payment_and_seller_stripe_account_present?,
      :send_confirmed?,
      :buyer_can_request_confirmation?,
      :buyer_can_request_refund?,
      :confirmation_requested_at_pretty,
      :refund_requested_at_pretty,
      :book_title,
      :accepted?,
      :internal,
      :send_confirmed?,
      :in_buyer_activity_feed?,
      :in_buyer_sent_feed?,
      :date_to_s,
      :date_pretty,
      :in_past,
      :refunded?,
      :refundable?
  ]

  enum inv_type: { "feature" => "feature", "mention" => "mention", "solo" => "solo" }

  def has_payment_offer_or_swap_offer
    if !payment_offer? && !swap_offer?
      errors.add(:base, "Must include a payment offer or a swap offer")
    end
  end

  def offer_types
    if swap_offer? && payment_offer?
      return "swap or paid booking"
    end
    if swap_offer?
      return "swap"
    end
    if payment_offer?
      return "paid booking"
    end
    nil
  end

  def set_recorded_list_name
    self.recorded_list_name = self.list.adopted_pen_name
  end

  def valid_swap_offer
    if swap_offer?
      if (!swap_offer_list.present? || !swap_offer_inv_types.present?) && !swap_reservation.present?
        errors.add(:base, "Invalid swap offer")
      end
    end
  end

  def valid_payment_offer
    if payment_offer?
      if payment_offer_total < 0
        errors.add(:base, "Payment offer may not be for less than $0")
      end
    end
  end

  def payment_offer_total
    price.to_i + premium.to_i
  end

  def zero_dollar_offer?
    payment_offer? && payment_offer_total == 0
  end

  def swap_offer_inv_types
    result = []
    result << "solo" if swap_offer_solo?
    result << "feature" if swap_offer_feature?
    result << "mention" if swap_offer_mention?
    result
  end

  def swap_offer_accepted?
    swap_offer? && accepted? && swap_reservation_id?
  end

  def payment_offer_accepted?
    payment_offer? && accepted? && !swap_reservation_id?
  end

  def open_swap_offer?
    swap_offer? && swap_offer_list.present? && pending?
  end

  def uid
    "r#{id}"
  end

  def price_in_play?
    payment_offer? && !swap_offer_accepted?
  end

  def swap_in_play?
    swap_offer? && !payment_offer_accepted?
  end

  def date_pretty
    date.pretty
  end

  def created_at_pretty
    created_at.to_date.pretty
  end

  def cancelled_reason
    reason = seller_cancelled_reason.presence || system_cancelled_reason.presence
    reason.gsub("_", " ") if reason
  end

  def date_in_english
    date.in_english
  end

  def paid?
    (payment_offer_accepted? && zero_dollar_offer?) || swap_offer_accepted? || refundable_payment.present?
  end

  def refunded?
    connect_payments.select(&:refunded?).present?
  end

  def refundable_payment
    connect_payments.reject(&:refunded?).first
  end

  def paid_on
    refundable_payment.try(:paid_on)
  end

  def stripe_payment_amount
    payment_offer_total.to_i*100
  end

  def seller_stripe_acct_id
    seller_stripe_account&.acct_id
  end

  def refundable_amount
    refundable_payment.present? ? refundable_payment.amount.to_i/100 : nil
  end

  def refund_amount
    if (refund = connect_refunds.first).present?
      refund.amount.to_i/100
    end
  end

  def buyer_payment_page_link
    SITE_URL + "/reservations/#{id}/pay"
  end

  def book_title
    book.try(:title)
  end

  def book_author
    book.try(:author)
  end

  def buyer_yet_to_be_invoiced?
    accepted? && !paid? && !buyer_invoiced_at?
  end

  def accepted?
    #I.e. Currently in a state of accepted.  It doesn't mean it was simply at one point accepted
    seller_accepted_at? && !cancelled? && !refunded?
  end

  def refundable?
    refundable_payment.present?
  end

  def declined?
    seller_declined_at?
  end

  def cancelled?
    seller_cancelled_at? || system_cancelled_at? || buyer_cancelled_at?
  end

  def pending?
    !cancelled? && !seller_accepted_at? && !seller_declined_at?
  end

  def get_status
    return "refunded" if refunded?
    return "sent" if send_confirmed?
    return "swapped" if swap_offer_accepted?
    return "paid" if paid?
    return "accepted" if accepted?
    return "declined" if declined?
    return "cancelled" if cancelled?
    return "pending" if pending?
    return "expired"
  end

  def get_status_plus
    return "refunded" if refunded?
    return "sent" if send_confirmed?
    return "refund requested" if refund_requested_at?
    return "confirmation requested" if !cancelled? && confirmation_requested_at?
    return "swapped" if swap_offer_accepted?
    return "paid ($#{payment_offer_total})" if paid?
    return "accepted - awaiting payment" if accepted?
    return "declined" if declined?
    return "cancelled#{" by buyer" if buyer_cancelled_at?}" if cancelled?
    return "pending seller decision" if pending?
    return "expired"
  end

  def status
    @status ||= get_status
  end

  def status_plus
    @status_plus ||= get_status_plus
  end

  def awaiting_payment?
    self.status == "accepted"
  end

  def awaiting_payment_and_seller_stripe_account_present?
    awaiting_payment? && seller_stripe_account.present?
  end

  def awaiting_payment_and_seller_stripe_account_missing?
    awaiting_payment? && !seller_stripe_account.present?
  end

  def seller_accept_url
    SITE_URL + "/reservations/#{id}/accept"
  end

  def seller_accept_swap_url
    SITE_URL + "/swap_calendar/#{id}"
  end

  def seller_decline_url
    SITE_URL + "/reservations/#{id}/decline"
  end

  def in_buyer_activity_feed?
    !dismissed_from_buyer_activity_feed_at?
  end

  def in_buyer_sent_feed?
    !dismissed_from_buyer_sent_feed_at?
  end

  def save_one_day_inventory
    list.auto_handle_one_day_inventory!(self.date) if list
  end

  def internal
    true
  end

  def list_size
    list.try(:active_member_count)
  end

  def list_name
    list.adopted_pen_name
  end

  def booking_details_info_link
    url = SITE_URL + "/reservations/" + self.id.to_s + "/info"
    "<a target='_blank' href='#{url}'>details</a>".html_safe
  end

  def buyer_recipients(filter = nil)
    result = buyer.self_with_assistants.select(&:email_verified?)
    
    if filter == :confirmations
      result.select(&:confirmations_subscribed?)
    elsif filter == :bookings
      result.select(&:bookings_subscribed?)
    else
      result
    end
  end

  def date_to_s
    date.to_s
  end

  def in_past
    date < Date.today_in_local_timezone
  end

  def clazz
    self.class.to_s
  end

  def cancellable_swap?(min_days_before = 7)
    swap_offer_accepted? && swap_reservation.try(:swap_offer_accepted?) && [self, swap_reservation].map(&:date).min - Date.today_in_local_timezone >= min_days_before
  end
  
  def last_minute_cancellable_swap?
    cancellable_swap?(1)
  end
  
  def last_minute_refundable?
    refundable? && !send_confirmed? && self.date > 2.weeks.ago
  end
  
  def cancel_swap_as_seller!(seller_cancelled_reason)
    self.update(seller_cancelled_at: Time.now, seller_cancelled_reason: seller_cancelled_reason.presence)
    self.swap_reservation.update(buyer_cancelled_at: Time.now)
    HandleCancelJob.perform_async(self.id)
  end
  
  def cancel_swap_as_buyer!
    self.update(buyer_cancelled_at: Time.now)
    self.swap_reservation.update(seller_cancelled_at: Time.now)
    HandleCancelJob.perform_async(self.swap_reservation.id)
  end
  
  def cancellable_unpaid_promo?
    (payment_offer_accepted? && !connect_payments.present? && self.date > Date.today_in_local_timezone) || pending?
  end
  
  def swap_where_only_this_side_is_outstanding?
    swap_offer_accepted? && swap_reservation.try(:send_confirmed?) && !self.send_confirmed?
  end

  def swap_reservation_date
    swap_reservation.try(:date_pretty)
  end

  def default_payment_source
    @default_payment_source ||= buyer.bc_customer.try(:default_source)
  end

  def buyer_can_request_confirmation?
    return false if confirmation_requested_at?
    return false if !needs_confirm?
    Time.now - campaigns_fetched_at > 48.hours
  end

  def buyer_can_request_cancel_and_refund?
    return false unless self.date > Date.today_in_local_timezone
    return false if refund_requested_at?
    return false unless refundable?
    return true
  end

  def confirmation_requested_at_pretty
    self.confirmation_requested_at && self.confirmation_requested_at.strftime("%B %d, %Y at %H:%M")
  end

  def buyer_can_request_refund?
    return false if refund_requested_at?
    return false if !confirmation_requested_at?
    return false if !needs_confirm?
    return false if !refundable?
    Time.now - confirmation_requested_at > 72.hours
  end

  def refund_requested_at_pretty
    self.refund_requested_at && self.refund_requested_at.strftime("%B %d, %Y at %H:%M")
  end

  def prohibitive_refund_request?
    self.refund_requested_at? && needs_confirm? && refundable?
  end

  def value_text
    if swap_offer? && payment_offer?
      ""
    elsif swap_offer?
      "(swap request)"
    elsif payment_offer?
      "(amt $#{payment_offer_total})"
    end
  end
  
  def self.settle_associated_reservations_json(association_entity_or_array)
    association_entity_or_array.as_json(
      only: [:id, :adopted_pen_name, :title],
      include: {
        reservations_unconcluded: { 
          only: [:id, :date, :inv_type], 
          methods: [
            :needs_confirm?,
            :cancellable_unpaid_promo?, 
            :last_minute_refundable?, 
            :last_minute_cancellable_swap?, 
            :swap_where_only_this_side_is_outstanding?,
            :book_title, :book_author, 
            :date_pretty] 
        }
      }
    )
  end

end
