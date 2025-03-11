class ListCalendar
  
  def initialize(list, start_date, end_date, view_as: :seller, books: nil, swap_reservation: nil)
    @list = list
    @start_date = start_date
    @end_date = list.cutoff_date || end_date
    @view_as = view_as
    @books = books
    @swap_reservation = swap_reservation
    init_dates
  end
  
  def process!
    process_inventories
    process_external_reservations
    process_reservations
  end
  
  def seller?
    @view_as == :seller
  end
    
  def buyer?
    @view_as == :buyer
  end
  
  def dates
    @dates_data.keys
  end

  def future_dates
    dates.select { |date| date >= Date.today_in_local_timezone }
  end
  
  def process_inventories
    selected_inv_types = @swap_reservation.try(:swap_offer_inv_types) || Inventory.all_types

    @list.inventories.where(inv_type: selected_inv_types).each do |inventory|
      add_inventory(inventory)
    end
    
    odi_scope = buyer? ? :future : :all
    @list.one_day_inventories.send(odi_scope).each do |one_day_inventory|
      add_one_day_inventory(one_day_inventory, selected_inv_types)
    end
  end
  
  def process_external_reservations
    external_reservations.each do |res|
      delete_inventory_by_date(res.date, res.inv_type)
      if seller?
        add_external_reservation(res)
      end 
    end
  end
  
  def add_external_reservation(res)
    get_date(res.date).external_reservations << res
  end
  
  def process_reservations
    reservations.select(&:pending?).each do |res|
      if seller?
        add_pending_reservation(res)
      elsif buyer?
        if @books.map(&:id).include?(res.book_id)
          delete_inventory_by_date(res.date, :all)
          add_pending_reservation(res)
        end
      end
    end
    
    reservations.select(&:accepted?).each do |res|
      if seller?
        delete_inventory_by_date(res.date, res.inv_type)
        add_confirmed_reservation(res)
      elsif buyer? 
        if @books.map(&:id).include?(res.book_id)
          delete_inventory_by_date(res.date, :all)
          add_confirmed_reservation(res)
        else
          delete_inventory_by_date(res.date, res.inv_type)
        end
      end
    end
  end
  
  def add_pending_reservation(res)
    get_date(res.date).pending_reservations << res
  end
    
  def add_confirmed_reservation(res)
    get_date(res.date).confirmed_reservations << res
  end
  
  def add_inventory(inventory)
    days_of_week = DAYS_OF_WEEK.select { |day| inventory[day].to_i > 0 }
    days = days_of_week.map { |day| DAYS_OF_WEEK.index(day) }
    
    dates_scope = buyer? ? future_dates : dates
    
    dates_scope.select {|k| days.include?(k.wday) }.each do |date|
      get_date(date).add_inventory(inventory.inv_type, inventory[date.day_of_week].to_i)
    end
  end

  def add_one_day_inventory(one_day_inventory, inv_types)
    delete_inventory_by_date(one_day_inventory.date, :all)
    inv_types.each do |inv_type|
      get_date(one_day_inventory.date).add_inventory(inv_type, one_day_inventory[inv_type].to_i)
    end
  end
  
  def delete_inventory_by_date(date, inv_type)
    get_date(date).delete_inventory(inv_type)
  end
  
  def reservations
    @reservations ||= @list.reservations.includes({book: [:user, :pen_name]}, :promo_send_confirmation, :connect_payments)
  end
  
  def external_reservations
    @external_reservations ||= @list.external_reservations.includes(:promo_send_confirmation)
  end
  
  def init_dates
    @dates_data = {}
    (@start_date..@end_date).to_a.each do |date|
      @dates_data[date] = DateData.new(date)
    end
  end
  
  def get_date(date)
    @dates_data[date] ||= DateData.new(date)
  end
  
  class DateData
    
    attr_accessor :available_inventory
    attr_accessor :external_reservations, :pending_reservations, :confirmed_reservations
    
    def initialize(date)
      @date = date
      @available_inventory = Hash.new { |h,k| h[k] = 0 }
      @pending_reservations = []
      @confirmed_reservations = []
      @external_reservations = []
    end
    
    def add_inventory(inventory_type, amount)
      if amount > 0
        @had_inventory = true
        @available_inventory[inventory_type] += amount
      end
    end
    
    def delete_inventory(inventory_type, amount = 1)
      if inventory_type == :all
        @had_inventory = false
        @available_inventory = Hash.new { |h,k| h[k] = 0 }
      else
        @available_inventory[inventory_type] -= amount
        @available_inventory.select! { |k,v| v > 0 }
      end
    end
    
    def has_booking?
      confirmed_reservations.present? || pending_reservations.present? || external_reservations.present?
    end
    
    def has_booking_that_needs_attention?
      confirmed_reservations.any?(&:needs_confirm?) || external_reservations.any?(&:needs_confirm?) || pending_reservations.present?
    end
    
    def fully_booked?
      @had_inventory && available_inventory.blank?
    end
    
  end
  
  
end