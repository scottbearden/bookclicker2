import React from 'react';
import { Redirect } from 'react-router';
import BookingForm from './BookingForm';
import PageTitle from '../PageTitle';
import withBookingCalendar from '../shared/withBookingCalendar';

const num_months_lookahead = 12;

class BookingCalendar extends React.Component {

  render() {
    if (location.search.slice(1) != this.props.stateAsQueryString()) {
      let newPath = document.location.pathname + "?" + this.props.stateAsQueryString();
      return <Redirect to={newPath} />
    }

    let subtitles = [];
    subtitles.push(this.props.list.adopted_pen_name)
    if (this.props.list.active_member_count_delimited) {
      subtitles.push(this.props.list.active_member_count_delimited + " active subscribers.")
    }
    return (
      <div>
        <PageTitle title={"Request Promo"} subtitles={subtitles} />
        <div className="loading-calendar" style={{display: this.props.showLoadingAnimation ? "block" : "none"}}>
          <img src={BookclickerStaticData.wheelSvg}/>
          <div>Loading Calendar</div>
        </div>
        <div id="booking-calendar" className="zabuto-calendar-container"></div>
      </div>
    )
  }
  
}

const BookingCalendarWithBookingCalendar = withBookingCalendar(BookingCalendar, BookingForm);
export default BookingCalendarWithBookingCalendar;