class ExternalReservation < ApplicationRecord

  belongs_to :list
  has_one :seller, through: :list, source: :user
  has_one :promo_send_confirmation, -> { external }, foreign_key: :reservation_id
  belongs_to :buyer_by_email, class_name: '::User', foreign_key: :book_owner_email, primary_key: :email
  include ConfirmationsConcern

  validate :no_script_tags

  before_create :set_recorded_list_name
  after_commit :save_one_day_inventory

  # validates_format_of :book_owner_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, allow_blank: true

  enum inv_type: {
    "feature" => "feature",
    "mention" => "mention",
    "solo" => "solo"
  }

  def book_author
    book_owner_name
  end

  def declined?
    nil
  end

  def cancelled?
    false
  end

  def pending?
    nil
  end

  def accepted?
    true
  end

  def refunded?
    false
  end

  def refundable?
    false
  end

  def swap_reservation
    nil
  end

  def im_sending_this
    true
  end

  def book_details
    result = ""
    if book_owner_name.present?
      result << "  The author is #{book_owner_name}."
    end
    if book_owner_email.present?
      result << "  The author's email is #{book_owner_email}."
    end
    if book_title.present?
      result << "  The title of the book is <i>#{book_title}</i>"
    end
    result.presence
  end

  def no_script_tags
    [book_title, book_owner_email, book_owner_name].each do |f|
      errors.add(:base, "cannot include script tags") if f.present? && f.match(/[\<\>]/)
    end
  end

  def book
    @book = Book.new(title: book_title, author: book_owner_name)
    @book.book_links.new(link_url: self.book_link) if self.book_link.present?
    @book
  end

  def internal
    false
  end

  def uid
    "er#{id}"
  end

  def save_one_day_inventory
    list.auto_handle_one_day_inventory!(self.date) if list
  end

  def in_past
    self.date && self.date < Date.today_in_local_timezone
  end

  def status
    "manual booking"
  end

  def status_plus
    "manual booking"
  end

  def paid?
    false
  end

  def date_pretty
    date.pretty
  end

  def in_past
    date < Date.today_in_local_timezone
  end

  def price_in_play?
    false
  end

  def swap_in_play?
    false
  end

  def payment_offer?
    false
  end

  def swap_offer?
    false
  end

  def payment_offer_accepted?
    false
  end

  def swap_offer_accepted?
    false
  end

  def payment_offer_total
    nil
  end

  def swap_offer_inv_types
    []
  end

  def clazz
    self.class.to_s
  end

  def find_or_invent_buyer
    buyer_by_email || User.new(name: self.book_owner_name, email: self.book_owner_email, bookings_subscribed: true)
  end

  def buyer
    @buyer ||= find_or_invent_buyer
  end

  def value_text
    ""
  end

  def set_recorded_list_name
    self.recorded_list_name = self.list.adopted_pen_name
  end

end