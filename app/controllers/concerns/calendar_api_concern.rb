module CalendarApiConcern
  extend ActiveSupport::Concern
  
  def prepare_list_calendar
    data = {}
    @list_calendar.dates.each do |date|
      data[date.to_s] = {
        body: get_html(date),
        tooltip: build_tooltip(date),
        title: date.to_s,
        date: date.to_s,
        next_date: (date + 1.day).to_s,
        previous_date: (date - 1.day).to_s,
        pretty_title: date.pretty,
        unavailable: false,
        classname: calendar_badge_css_class(date),
      }
    end
    data
  end
  
  def start_date
    params[:num_of_months].to_i.months.ago.beginning_of_month.to_date
  end
  
  def end_date
    params[:num_of_months].to_i.months.from_now.end_of_month.to_date
  end
  
end
