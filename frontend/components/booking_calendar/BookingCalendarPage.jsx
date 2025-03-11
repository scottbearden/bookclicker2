import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import BookingCalendarWithBookingCalendar from './BookingCalendarWithBookingCalendar';
import SwapCalendarWithBookingCalendar from './SwapCalendarWithBookingCalendar';

export default class BookingCalendarPage extends React.Component {

  render() {
    
    return (
      <div id="booking-calendar-page">
        <BrowserRouter>
          <div>
            <Route path="/booking_calendar/:list_id(\d+)" render={() => (
              <div>
                <BookingCalendarWithBookingCalendar 
                  preselected_book={this.props.preselected_book}
                  list={this.props.list}  />
              </div>
            )}>
            </Route>
            <Route path="/swap_calendar/:reservation_id(\d+)" render={() => (
              <div>
                <SwapCalendarWithBookingCalendar 
                  list={this.props.list} 
                  reservation={this.props.reservation} />
              </div>
            )}>
            </Route>
          </div>
        </BrowserRouter>
     </div>
    )
    
  } 
}