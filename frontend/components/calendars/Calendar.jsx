import React from 'react';
import ReactDOM from 'react-dom';
import { Redirect } from 'react-router';
import CalendarDayBookings from './CalendarDayBookings'
import CalendarDayEditInventory from './CalendarDayEditInventory';
import ConfirmPromoSelect from '../confirm_promos/ConfirmPromoSelect';
import CalendarsApi from '../../api/CalendarsApi';
import ConfirmPromosApi from '../../api/ConfirmPromosApi';
import { objectValues, injectAuthenticityToken, hex } from '../../ext/functions';
import queryString from 'query-string';

const num_months_lookahead = 12;

export default class Calendar extends React.Component {
  
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
  
  componentDidMount() {
    this.reloadDates();
    var that = this;
    $('#reusableModal').on('hidden.bs.modal', function () {
      that.reloadDates()
    });
  }
  
  reloadDates() {
    var that = this;
    CalendarsApi.getAvailability({
      list_id: this.props.list.id,
      num_of_months: num_months_lookahead
    }).then(res => {
      this.setState({dates: res.dates, showLoadingAnimation: false});
    });
  }
  
  componentDidUpdate() {
    this.initCalendar()
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
  
  zabutoCalendarOptions(data) {
    var that = this;
    var options = {
      show_next: num_months_lookahead, 
      show_previous: num_months_lookahead,
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
  
  initCalendarDay(date) {
    
    let editInventoryForm = $('#reusableModal .modal-footer').html('<div id="CalendarDayEditInventory"></div>').find('#CalendarDayEditInventory')[0]
    ReactDOM.render(
      <CalendarDayEditInventory 
        list={this.props.list}
        isMobile={this.props.isMobile}
        reloadDates={this.reloadDates.bind(this)}/>, editInventoryForm)
      
    let calDayBookings = $('#reusableModal .modal-body').html("<div id='CalendarDayBookings'></div>").find('#CalendarDayBookings')[0]
    ReactDOM.render(
      <CalendarDayBookings 
        list={this.props.list} 
        isMobile={this.props.isMobile}
        openConfirmPromoSelect={this.openConfirmPromoSelect.bind(this)}
        date={date} 
        reloadDates={this.reloadDates.bind(this)}/>, calDayBookings)
  }
  
  openConfirmPromoSelect(reservation_id, reservation_type) {
    var that = this;
    ConfirmPromosApi.fetchOptions(reservation_id, reservation_type).then(res => {
      let calConfirmPromo = $('#reusableModal .modal-body').html("<div id='CalendarConfirmPromo'></div>").find('#CalendarConfirmPromo')[0]
      ReactDOM.render(
        <ConfirmPromoSelect
          reservation={res.reservation} 
          book={res.reservation.book}
          buyer={res.reservation.buyer}
          onConfirm={that.onDateClick.bind(that, {title: res.reservation.date})}
          seller={that.props.seller} 
          list={res.reservation.list} />, calConfirmPromo)
    })
  }
  
  onDateClick(calendarTarget) {
    var date = calendarTarget.title;
    if (!date) return null
    var dateData = this.state.dates[date];
    if (!dateData) return null;
    var $modal = $('#reusableModal');
    
    let randomId = "calendar-title-" + hex(8);
    $modal.find('.modal-title').html(this.modalTitleHtml(dateData, randomId));
    this.setNextPreviousLinksListeners(dateData, randomId);
    
    $modal.find('.modal-header').find('button.close').addClass('not-phone');

    this.initCalendarDay(date)
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
  
  onMonthNav(calendarTarget) {
    var nav = $("#" + calendarTarget.id).data("navigation");
    let { month, year } = $("#" + calendarTarget.id).data("to");
    this.setState({month, year});
    this.initTooltips();
  }

  initTooltips() {
    var that = this;
    $('.dow-clickable').each(function(idx, calendarTarget) {
      if (calendarTarget.title) {
        var dateData = that.state.dates[calendarTarget.title];
        if (dateData.tooltip) {
          var $button = $(calendarTarget).find('.day');
          $button.data('tooltip', 'toggle');
          $button.tooltip({placement: 'top', html: true, title: dateData.tooltip});
        }
      }
    })
  }
  
  stateAsQueryString() {
    let { month, year } = this.state;
    let queryStr = queryString.stringify({ month, year });
    return queryStr;
  }
    
  render() {
    if (location.search.slice(1) != this.stateAsQueryString()) {
      let newPath = document.location.pathname + "?" + this.stateAsQueryString();
      return <Redirect to={newPath} />
    }
    
    return (
      <div>
        <div className="loading-calendar" style={{display: this.state.showLoadingAnimation ? "block" : "none"}}>
          <img src={BookclickerStaticData.wheelSvg}/>
          <div>Loading Calendar</div>
        </div>
        <div id="calendar" className="zabuto-calendar-container">
        </div>
      </div>
    )
  }
  
}