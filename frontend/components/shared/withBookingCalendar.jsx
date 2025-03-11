import React from 'react';
import queryString from 'query-string';
import ReactDOM from 'react-dom';
import BookingCalendarsApi from '../../api/BookingCalendarsApi';
import { objectValues, hex } from '../../ext/functions';

const NUM_MONTHS_LOOKAHEAD = 12;

const withBookingCalendar = (WrappedComponent, BookingFormComponent) => {
  // ...and returns another component...
  return class extends React.Component {

    constructor(props) {
      super(props);
      const qs = queryString.parse(location.search);
      this.state = {
        dates: [],
        month: qs.month ? parseInt(qs.month) : undefined,
        year: qs.year ? parseInt(qs.year) : undefined,
        showLoadingAnimation: true
      };
    }

    componentDidUpdate() {
      this.initCalendar();
    }
    
    initCalendar() {
      var datesData = objectValues(this.state.dates);
      var that = this;
      $('.zabuto-calendar-container').html('')
      $('.zabuto-calendar-container').zabuto_calendar(this.zabutoCalendarOptions(datesData));
      $('.dow-clickable').off('click touchend');
      $('.dow-clickable').on('click touchend', function(event) {
        let regex = RegExp(/_(20\d{2}-\d{2}-\d{2})_day/);
        let elemId = event.target ? (event.target.id || event.target.parentElement.id) : ""
        let date = elemId.match(regex) && elemId.match(regex)[1];
        if (date) {
          that.onDateClick({title: date});
        }
      });
      that.initTooltips();
    }

    initBookingFormListener(elSelector, date, datePretty) {
      var that = this;
      $(elSelector).on('click touchend', event => {
        event.preventDefault();
        var $target = $(event.target);
        var bookingForm = $target.parents('.modal-body').find('.BookingForm')[0];
        ReactDOM.render(
          <BookingFormComponent 
            list={that.props.list} 
            preselected_book={this.props.preselected_book}
            reservation={this.props.reservation}
            invType={$target.data('inv_type')} 
            date={date}
            datePretty={datePretty} />, bookingForm)
      })
    }

    onDateClick(calendarTarget) {
      var date = calendarTarget.title;
      if (!date) return null;
      var dateData = this.state.dates[date];
      if (!dateData) return null;
      var $modal = $('#reusableModal');

      $modal.find('.modal-body').html(dateData.body || '<div style="text-align:center;">This date is unavailable</div>');
      $modal.find('.modal-footer').html(this.modalFooterListInfo());
      
      let randomId = "calendar-title-" + hex(8);
      $modal.find('.modal-title').html(this.modalTitleHtml(dateData, randomId));
      this.setNextPreviousLinksListeners(dateData, randomId);

      $modal.find('.modal-header').find('button.close').addClass('not-phone');
      $modal.find('input[name="date"]').each(function(i, dateInput) {
        $(dateInput).val(date);
      })
      this.initBookingFormListener('.reserve-form-submit', date, dateData.pretty_title);
      $modal.modal({
        keyboard: true
      })
    }
    
    setNextPreviousLinksListeners(dateData, elemId) {
      var that = this;
      $('#' + elemId).find('.next-day-link').on('click', function() {
        that.onDateClick({title: dateData.next_date});
      })
      
      $('#' + elemId).find('.previous-day-link').on('click', function() {
        that.onDateClick({title: dateData.previous_date});
      })
    }

    initTooltips() {
      var that = this;
      $('.dow-clickable').each(function(idx, calendarTarget) {
        if (calendarTarget.title) {
          var dateData = that.state.dates[calendarTarget.title];
          if (dateData.tooltip) {
            var $button = $(calendarTarget).find('.day');
            $button.data('tooltip', 'toggle');
            $button.tooltip({placement: 'top', html: true, title: dateData.tooltip });
          }
        }
      })
    }

    zabutoCalendarOptions(data) {
      var that = this;
      var options = {
        show_next: NUM_MONTHS_LOOKAHEAD, 
        show_previous: NUM_MONTHS_LOOKAHEAD,
        show_days: true,
        today: true,
        weekstartson: 0,
        data: data,
        action: function() { 
          return null;
        },
        action_nav: function() {
          that.onMonthNav(this);
        }
      }
      if (this.state.year) {
        options["year"] = this.state.year;
      }
      if (this.state.month) {
        options["month"] = this.state.month;
      }
      return options;
    }

    componentDidMount() {
      var that = this;
      BookingCalendarsApi.getAvailability({
        list_id: this.props.list.id,
        num_of_months: NUM_MONTHS_LOOKAHEAD,
        swap_reservation_id: (this.props.reservation ? this.props.reservation.id : null)
      }).then(res => {
        that.setState({dates: res.dates, showLoadingAnimation: false});
      })
    }
    
    modalTitleHtml(dateData, randomId) {
      let result = "";
      result += "<div class='calendar-modal-title-container'>";
      result +=   "<div class='calendar-modal-title' id='" + randomId + "'>";
      result +=     "<a class='previous-day-link'>";
      result +=       "<span class='glyphicon glyphicon-arrow-left next-previous-day-icon'></span>";
      result +=     "</a>";
      result +=     "<span class='calendar-modal-title-date'>" + dateData.pretty_title + "</span>";
      result +=     "<a class='next-day-link'>";
      result +=       "<span class='glyphicon glyphicon-arrow-right next-previous-day-icon'></span>";
      result +=     "</a>";
      result +=   "</div>";
      result += "</div>";
      return result;
    }

    modalFooterListInfo() {
      let result = "<div class='justify'>";
      result += "<span class='big'>" + this.props.list.adopted_pen_name + "</span>";
      result += '<br/>Size: ' + this.props.list.active_member_count_delimited;
      if (this.props.list.open_rate && this.props.list.open_rate > 0.0) {
        result += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
        result += 'Open Rate: ' + Math.round(this.props.list.open_rate*1000)/10 + '%';
      }
      if (this.props.list.click_rate && this.props.list.click_rate > 0.0) {
        result += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
        result += 'Click Rate: ' + Math.round(this.props.list.click_rate*1000)/10 + '%';
      }

      result += '</div>';
      return result;
    }

    stateAsQueryString() {
      let { month, year } = this.state;
      let queryStr = queryString.stringify({ month, year });
      return queryStr;
    }

    onMonthNav(calendarTarget) {
      var nav = $("#" + calendarTarget.id).data("navigation");
      let { month, year } = $("#" + calendarTarget.id).data("to");
      this.setState({month, year});
      this.initTooltips();
    }

    render() {
      return (
        <WrappedComponent 
          {...this.props} 
          showLoadingAnimation={this.state.showLoadingAnimation}
          stateAsQueryString={this.stateAsQueryString.bind(this)} />);
    }
  };
}

export default withBookingCalendar;