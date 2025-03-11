class Book < ApplicationRecord
  belongs_to :user
  belongs_to :pen_name, -> { unscope(where: :deleted) }
  validates_presence_of :title
  validate :valid_pen_name
  validate :can_delete?, if: proc { deleted? && deleted_changed? }

  has_many :book_links, dependent: :destroy, inverse_of: :book
  has_many :reservations
  has_many :reservations_unconcluded, -> { accepted.unconfirmed.in_last_months(6) }, class_name: Reservation, foreign_key: :book_id
  has_many :reservations_not_cancelled, -> { not_cancelled }, class_name: Reservation, foreign_key: :book_id
  has_many :recent_reservations_feed, -> { where("reservations.date > ?", Date.today_in_local_timezone - 30.days).order(:date) }, class_name: Reservation, foreign_key: :book_id
  has_many :promos, -> { order(:date) }, dependent: :destroy
  accepts_nested_attributes_for :book_links, allow_destroy: true, reject_if: Proc.new { |bl| bl['link_url'].blank? }
  accepts_nested_attributes_for :promos, allow_destroy: true, reject_if: Proc.new { |pr| ["list_size", "date"].any? { |pr_attr| pr[pr_attr].blank? } }
  attr_accessor :uuid_order

  def self.launch_order_sql
    "CASE WHEN launch_date IS NULL THEN 1 ELSE 0 END ASC, launch_date, books.created_at"
  end

  scope :active, -> { where(deleted: false) }

  default_scope { active.order(launch_order_sql) }

  JSON_WITH_LINKS = {
    include: [:book_links],
    methods: [:author, :amazon_link_url, :google_play_link_url, :itunes_link_url, :other_link_urls, :launch_date_in_english, :can_delete?]
  }

  def title
    deleted? ? "< info deleted >" : self[:title]
  end

  def last_booking
    @last_booking ||= reservations.accepted_or_pending.last
  end

  def can_delete?
    if last_booking && last_booking.date >= CAN_DELETE_STUFF_AFTER.ago
      errors.add(:base, "Must wait 3 weeks from date of last marketplace activity before deleting book.  You may delete on or after #{(last_booking.date + CAN_DELETE_STUFF_AFTER + 1.day).pretty}")
      false
    else
      true
    end
  end

  def as_json_with_links
    as_json(JSON_WITH_LINKS)
  end

  def amazon_link_url
    book_links.select(&:amazon?).first.try(:link_url)
  end

  def google_play_link_url
    book_links.select(&:google_play?).first.try(:link_url)
  end

  def itunes_link_url
    book_links.select(&:itunes?).first.try(:link_url)
  end

  def other_link_urls
    book_links.reject(&:amazon?).reject(&:google_play?).reject(&:itunes?).map(&:link_url)
  end

  def valid_pen_name
    if !pen_name.present? || pen_name.promo_service_only? || !pen_name.users_pen_names.pluck(:user_id).include?(self.user_id)
      errors.add(:base, "Books must have valid pen name")
    end
  end

  def two_day_peak
    best = 0
    promo_emails_by_day.keys.sort.each do |date_key|
      day1 = promo_emails_by_day[date_key]
      day1_weighted_count = day1.solos + (day1.features * 0.5) + (day1.mentions * 0.25)
      if promo_emails_by_day[date_key + 1.day]
        day2 = promo_emails_by_day[date_key + 1.day]
        day2_weighted_count = day1.solos + (day1.features * 0.5) + (day1.mentions * 0.25)
        two_day_avg = (day1_weighted_count + day2_weighted_count)/2
      else
        two_day_avg = day1_weighted_count/2
      end
      best = [best, two_day_avg].max
    end
    best
  end

  def data_for_launch_page
    @data_for_launch_page ||= begin
      system_bookings = self.reservations.includes(:list, :swap_reservation, :connect_payments, :promo_send_confirmation).order(:date)
      {
        data_for_chart: LaunchCalculator.new(system_bookings.select(&:accepted?)).calculate,
        promos: system_bookings.as_json(methods: [:list_size, :list_name, :accepted?, :pending?, :status, :date_in_english, :cancellable_swap?, :cancellable_unpaid_promo?, :buyer_can_request_cancel_and_refund?])
      }
    end
  end

  def estimated_performance
    @estimated_performance ||= begin
      expected_sales = two_day_peak * 0.0125 * 0.5
      expected_sales *= 2 if self.format == 'kindle'
      expected_sales *= performance_price_factor
      case expected_sales.to_i.abs
      when 0
        nil
      when 1..4
        "Top 100,000"
      when 5..10
        "Top 50,000"
      when 11..24
        "Top 25,000"
      when 25..50
        "Top 10000"
      when 51..75
        "Top 5000"
      when 76..100
        "Top 3000"
      when 101..150
        "Top 1000"
      when 151..200
        "Top 500"
      when 201..300
        "Top 350"
      when 301..500
        "Top 200"
      when 501..1000
        "Top 100"
      when 1001..1500
        "Top 30"
      when 1501..2500
        "Top 20"
      else
        "Top 10"
      end
    end
  end

  def performance_price_factor
    case price.to_f.abs
    when (0.00)..(0.999)
      1.00
    when (1.00)..(2.999)
      0.75
    when (3.00)..(9.999)
      0.50
    else
      0.20
    end
  end

  def promos_in_uuid_order
    Promo.where(book_id: id).order(uuid_order_by_clause)
  end

  def uuid_order_by_clause
    @uuid_order.present? ? "field(uuid, '#{@uuid_order.join("','")}')" : "1"
  end

  def author
    @author ||= pen_name.try(:author_name)
  end

  def author=(author)
    @author = author
  end

  def launch_date_in_english
    launch_date.try(:in_english)
  end

end
