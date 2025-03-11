class ListSubscription < ApplicationRecord

  scope :subscribed, -> { where(opt_out_at: nil) }

  belongs_to :user
  belongs_to :list

  validates_format_of :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates_presence_of :email

  scope :order_by_activity, -> { order("coalesce(opt_out_at, opt_in_at) desc") }

  def self.handle_paid_reservation(reservation)
    r = reservation
    
    users = r.buyer.self_with_assistants.select(&:auto_subscribe_on_booking?)
    users.each do |user|
      list_subscription = ListSubscription.where(
        user_id: user.id,
        list_id: r.list_id
      ).first_or_create do |s|
        s.email = user.email_for_auto_subscribe
        s.opt_in_at = Time.now
        s.reservation_id = r.id
      end
      list_subscription.resubscribe if !list_subscription.subscribed?
    end
  end

  def unsubscribe
    self.update!(opt_out_at: Time.now)
  end

  def resubscribe
    update(
      email: user.email_for_auto_subscribe,
      opt_out_at: nil,
      opt_out_succeeded_at: nil,
      opt_out_failed_at: nil,
      opt_out_failed_message: nil,
      opt_in_at: Time.now,
      opt_in_succeeded_at: nil,
      opt_in_failed_at: nil,
      opt_in_failed_message: nil
    )
  end

  def subscribed?
    !opt_out_at?
  end

  def processed?
    if subscribed?
      opt_in_succeeded_at? || opt_in_failed_at?
    else
      opt_out_succeeded_at? || opt_out_failed_at?
    end
  end

  def unprocessed?
    !processed?
  end

  def process
    if subscribed?
      if Rails.env.production?
        process_subscribe!
      else
        self.update!(opt_in_succeeded_at: Time.now)
      end
    else
      if Rails.env.production?
        process_unsubscribe!
      else
        self.update!(opt_out_succeeded_at: Time.now)
      end
    end
  end

  def process_subscribe!
    subscriber = User.new
    subscriber.name = self.user.full_name || self.user.pen_names.pluck(:author_name).first
    res = list.subscribe(self.email, subscriber.first_name, subscriber.last_name)
    if res.success
      self.update!(opt_in_succeeded_at: Time.now)
    else
      self.update!(opt_in_failed_at: Time.now, opt_in_failed_message: res.message)
    end
  end

  def process_unsubscribe!
    res = list.unsubscribe(self.email)
    if res.success
      self.update!(opt_out_succeeded_at: Time.now)
    else
      self.update!(opt_out_failed_at: Time.now, opt_out_failed_message: res.message)
    end
  end

  def subscribed_on
    opt_in_at.to_date.american
  end

  def self.default_as_json
    {
      methods: [:subscribed_on, :subscribed?],
      except: [:user_id],
      include: { :list => { :only => [:name, :adopted_pen_name, :active_member_count] } }
    }
  end

end