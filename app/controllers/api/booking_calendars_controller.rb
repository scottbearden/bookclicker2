class Api::BookingCalendarsController < Api::BaseController
  include CalendarApiConcern

  before_action :require_current_member_user

  CSS_RESERVE_BUTTONS_MAP = {
    "solo" => "bclick-button bclick-solid-teal-button",
    "mention" => "bclick-button bclick-solid-deep-blue-button",
    "feature" => "bclick-button bclick-solid-sky-blue-button"
  }

  CSS_BADGE_CLASS_MAP = {
    "i_have_pending_bookings" => "bclick-button bclick-solid-yellow-button",
    "i_have_confirmed_bookings" => "bclick-button bclick-solid-sky-blue-button",
    "fully_booked" => "bclick-button bclick-solid-youtube-red-button",
    "unavailable-past" => "bclick-button bclick-solid-grey-button past no-hover-change unclickable",
    "yes_inventory" => "bclick-button bclick-solid-light-green-button",
    "no_inventory" =>  "bclick-button bclick-solid-grey-button"
  }

  def availability
    @list_calendar = ListCalendar.new(list, start_date, end_date, view_as: :buyer, books: current_member_user.books, swap_reservation: swap_reservation)
    @list_calendar.process!

    render json: {
      dates: prepare_list_calendar,
    }, status: :ok
  end

  def get_html(date)
    html = inventory_info_div(@list_calendar.get_date(date).available_inventory.keys)

    if @list_calendar.get_date(date).has_booking?
      html << bookings_header
      @list_calendar.get_date(date).pending_reservations.each do |res|
        html << reservation_info_div(res)
      end
      @list_calendar.get_date(date).confirmed_reservations.each do |res|
        html << reservation_info_div(res)
      end
      @list_calendar.get_date(date).external_reservations.each do |ext_res|
        html << external_reservation_info_div(ext_res)
      end
    elsif @list_calendar.get_date(date).fully_booked?
      html << is_fully_booked
    end
    html
  end

  def inventory_info_div(inv_types)
    return "" unless inv_types.present?
    return <<-HTML
      <div class="calendar-date-info-block">
        #{inv_types.map { |inv_type| reserve_form(inv_type) }.join()}
      <div>
      <div class="BookingForm">
      </div>
    HTML
  end

  def bookings_header(has_booking = true)
    <<-HTML
      <div class="calendar-date-info-block calendar-date-info-block-left #{'just-header' if has_booking}">
        <label class="calendar-date-header">Your Bookings</label>
        #{"<ul><li class='lightgrey'><span>None</span></li></ul>" if !has_booking}
      </div>
    HTML
  end

  def is_fully_booked
    <<-HTML
      <div style="text-align:center;">This date is fully booked</div>
    HTML
  end

  def external_reservation_info_div(x)
    raise "Should not be called - external_reservation_info_div"
  end

  def calendar_badge_css_class(date)
    if @list_calendar.get_date(date).pending_reservations.present?
      result = CSS_BADGE_CLASS_MAP["i_have_pending_bookings"]
    elsif @list_calendar.get_date(date).confirmed_reservations.present?
      result = CSS_BADGE_CLASS_MAP["i_have_confirmed_bookings"]
    elsif @list_calendar.get_date(date).fully_booked?
      result = CSS_BADGE_CLASS_MAP["fully_booked"]
    elsif date < Date.today_in_local_timezone
      result = CSS_BADGE_CLASS_MAP["unavailable-past"]
    elsif @list_calendar.get_date(date).available_inventory.present?
      result = CSS_BADGE_CLASS_MAP["yes_inventory"]
    else
      result = CSS_BADGE_CLASS_MAP["no_inventory"]
    end
    result += " past" if date < Date.today_in_local_timezone
    result
  end

  def reserve_form(inv_type)
    price_text = " - #{@list.price_text(inv_type)}" if !swap_reservation.present?
    <<-HTML
      <form class="reserve-form reserve-#{inv_type}" data-inv_type="#{inv_type}">
        <input
          type="submit"
          data-inv_type="#{inv_type}"
          value="#{"Swap for " if swap_reservation.present?}#{inv_type.titleize}#{price_text}"
          class="reserve-form-submit #{CSS_RESERVE_BUTTONS_MAP[inv_type]}"/>
      </form>
    HTML
  end

  def reservation_info_div(reservation)
    <<-HTML
      <div class="calendar-date-info-block calendar-date-info-block-left booking">
        <ul>
          <li>
            #{reservation.status.capitalize} #{reservation.inv_type.capitalize}:&nbsp;&nbsp;&nbsp;<a href="/reservations/#{reservation.id}/info" target="_blank">#{reservation.book.title}#{" by " + reservation.book.author if reservation.book.author.present?}</a>
          </li>
        </ul>
      </div>
    HTML
  end

  def build_tooltip(date)
    date_data = @list_calendar.get_date(date)
    if date_data.available_inventory.present?
      lis = date_data.available_inventory.keys.map do |inv_type|
        price_text = " - #{@list.price_text(inv_type)}" if !swap_reservation.present?
        "<div class='zabuto-day-tooltip-list-item'>#{inv_type.capitalize}#{price_text}</div>"
      end
      <<-HTML
        <div class='zabuto-day-tooltip-header'>
           Availability
        </div>
        <div class='zabuto-day-tooltip-list'>
          #{lis.join.html_safe}
        </div>
      HTML
    elsif date_data.has_booking?
      <<-HTML
        <div class='zabuto-day-tooltip-header'>
           Click To See Activity
        </div>
        <div class='zabuto-day-tooltip-list'>
        </div>
      HTML
    end
  end

  def list
    @list ||= List.status_active.find_by_id(params[:list_id])
  end

  def swap_reservation
    if params[:swap_reservation_id]
      @swap_reservation ||= current_member_user.reservations_as_seller.find_by_id(params[:swap_reservation_id]) || ""
    end
  end

end