class Api::CalendarsController < Api::BaseController
  include CalendarApiConcern

  before_action :require_current_member_user
  
  CSS_BADGE_CLASS_MAP = {
    "needs_attention" => "bclick-button bclick-solid-yellow-button",
    "fully_booked" => "bclick-button bclick-solid-youtube-red-button",
    "partially_booked" => "bclick-button bclick-solid-sky-blue-button",
    "unavailable-past" => "bclick-button bclick-solid-grey-button past",
    "available" => "bclick-button bclick-solid-light-green-button",
    "no_inventory" =>  "bclick-button bclick-solid-grey-button",
  }
  
  def availability
    @list_calendar = ListCalendar.new(list, start_date, end_date, view_as: :seller)
    @list_calendar.process!
    
    render json: {
      dates: prepare_list_calendar
    }, status: :ok
  end
      
  def list
    @list ||= current_member_user.lists.find(params[:list_id])
  end
  
  def calendar_badge_css_class(date)
    important = false
    if @list_calendar.get_date(date).has_booking_that_needs_attention?
      important = true
      result = CSS_BADGE_CLASS_MAP["needs_attention"]
    elsif @list_calendar.get_date(date).fully_booked?
      result = CSS_BADGE_CLASS_MAP["fully_booked"]
    elsif @list_calendar.get_date(date).has_booking?
      result = CSS_BADGE_CLASS_MAP["partially_booked"]
    elsif date < Date.today_in_local_timezone
      result = CSS_BADGE_CLASS_MAP["unavailable-past"]
    elsif @list_calendar.get_date(date).available_inventory.present?
      result = CSS_BADGE_CLASS_MAP["available"]
    else
      result = CSS_BADGE_CLASS_MAP["no_inventory"]
    end
    result += " past" if date < Date.today_in_local_timezone && !important
    result
  end
  
  def get_html(date)
    "<div id='CalendarDayBookings'></div>"
  end
  
  def inventory_info_div(inv_types)
    <<-HTML
      <div class="calendar-date-info-block calendar-date-info-block-left">
        <label class="calendar-date-header">Inventory For Today</label>
        <ul>
          #{inv_types.map { |inv_type| "<li><span>" + inv_type.titleize + "</span></li>" }.join }
          #{"<li class='lightgrey'><span>None</span></li>" if inv_types.blank?}
        </ul>
      </div>
    HTML
  end

  def bookings_header(has_booking = true)
    <<-HTML
      <div class="calendar-date-info-block calendar-date-info-block-left #{'just-header' if has_booking}">
        <label class="calendar-date-header">Bookings For Today</label>
        #{"<ul><li class='lightgrey'><span>None</span></li></ul>" if !has_booking}
      </div>
    HTML
  end
  
  def external_reservation_info_div(ext_reservation)
    if ext_reservation.inv_type == "date_unavailable"
      <<-HTML
        <div class="calendar-date-info-block">
          <p>
            This date has been marked as <b>unavailable</b>.&nbsp;&nbsp;
            #{"The following details were included -<br/>" + ext_reservation.book_details if ext_reservation.book_details}
          </p>
          #{external_reservation_destroy_form(ext_reservation)}
        </div>
      HTML
    else
      <<-HTML
        <div  class="calendar-date-info-block">
          <p>
            You have indicated that this date has a <b>#{ext_reservation.inv_type}</b> email.
            #{ext_reservation.book_details}
          </p>
          #{external_reservation_destroy_form(ext_reservation)}
        </div>
      HTML
    end
  end
  
  def external_reservation_destroy_form(ext_reservation)
    <<-HTML
      <form action="/external_reservations/#{ext_reservation.id}" method="POST">
        <input type="hidden" name="_method" value="delete">
        <input type="hidden" name="authenticity_token" class="form-authenticity-token" value="">
        <input type="submit" value="Cancel" class="calendar-date-reservation-button bclick-button bclick-solid-light-red-button"></input>
      </form>
    HTML
  end
  
  def reservation_info_div(reservation)
    if reservation.pending?
      <<-HTML
        <div class="calendar-date-info-block calendar-date-info-block-left booking">
          <ul>
            <li>
              #{reservation.inv_type.capitalize}:&nbsp;&nbsp;&nbsp;<a href="/reservations/#{reservation.id}/info" target="_blank">#{reservation.book.title}#{" by " + reservation.book.author if reservation.book.author.present?}</a>
              <br/>
              <a class="calendar-date-reservation-button bclick-button bclick-solid-notification-button-button" href="/reservations/#{reservation.id}/accept?cal_back=true">Accept</a>
              <a class="calendar-date-reservation-button bclick-button bclick-solid-dark-red-button" href="/reservations/#{reservation.id}/decline?cal_back=true">Decline</a>
            </li>
          </ul>
        </div>
      HTML
    else
      <<-HTML
        <div class="calendar-date-info-block calendar-date-info-block-left booking">
          <ul>
            <li>
              #{reservation.inv_type.capitalize}:&nbsp;&nbsp;&nbsp;<a href="/reservations/#{reservation.id}/info" target="_blank">#{reservation.book.title}#{" by " + reservation.book.author if reservation.book.author.present?}</a>
            </li>
          </ul>
        </div>
      HTML
    end
  end

  def build_tooltip(date)
    date_data = @list_calendar.get_date(date)
    result = ""
    if date_data.has_booking?
      groups = {:confirmed_reservations => "Confirmed", :pending_reservations => "Pending", :external_reservations => "External"}
      lis = []
      groups.each do |method, title|
        if date_data.send(method).present?
          date_data.send(method).each do |res|
            lis << <<-HTML
              <div class='zabuto-day-tooltip-list-item'>
                #{res.book_author || "???"}
              </div>
            HTML
          end
        end
      end
      
      result = <<-HTML
        <div class='zabuto-day-tooltip-header'>
          Bookings
        </div>
        <div class='zabuto-day-tooltip-list'>
          #{lis.join.html_safe}
        </div>
      HTML
      
    end
    result
  end
  
end






















