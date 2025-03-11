import React from 'react';
import OneDayInventoryApi from '../../api/OneDayInventoryApi';
import ExternalReservationsApi from '../../api/ExternalReservationsApi';
import CalendarDayBooking from './CalendarDayBooking';
import { hex } from '../../ext/functions';
import RespondBookingForm from '../booking_calendar/RespondBookingForm';
import RefundRescheduleForm from '../booking_calendar/RefundRescheduleForm';


export default class CalendarDayBookings extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      respondBooking: null,
      refundRescheduleBooking: null
    };
  }
  
  setRespondBooking(respondBooking) {
    this.setState({
      respondBooking,
      refundRescheduleBooking: null
    })
  }
  
  setRefundRescheduleBooking(refundRescheduleBooking) {
    this.setState({
      refundRescheduleBooking,
      respondBooking: null,
    })
  }
  
  notInPast() {
    var today = new Date();
    var yesterday = today.setDate(today.getDate() - 1);
    return Date.parse(this.props.date) > yesterday;
  }
  
  inPast() {
    return !this.notInPast();
  }
  
  noBookings() {
    return true 
    && !this.state.accepted_system_bookings.solo.length && !this.state.accepted_system_bookings.feature.length && !this.state.accepted_system_bookings.mention.length
    && !this.state.external_bookings.solo.length && !this.state.external_bookings.feature.length && !this.state.external_bookings.mention.length
    && !this.state.pending_system_bookings.solo.length && !this.state.pending_system_bookings.feature.length && !this.state.pending_system_bookings.mention.length
  }
  
  noInventory() {
    return !this.state.one_day_inventory.solo && !this.state.one_day_inventory.feature && !this.state.one_day_inventory.mention
  }
  
  componentDidMount() {
    this.loadData()
    var that = this;
    $('#reusableModal').off('inventory-changed')
    $('#reusableModal').on('inventory-changed', function($event, res) {
      if (res.date == that.props.date) {
        that.setState({
          one_day_inventory: res.one_day_inventory,
          remaining_inventory: res.remaining_inventory,
          pending_system_bookings: res.pending_system_bookings,
          accepted_system_bookings: res.accepted_system_bookings,
          external_bookings: res.external_bookings,
        })
      }
    })
  }
  
  loadData() {
    OneDayInventoryApi.get(this.props.date, this.props.list.id).then(res => {
      this.setState({
        loading: false,
        date: res.date,
        one_day_inventory: res.one_day_inventory,
        remaining_inventory: res.remaining_inventory,
        pending_system_bookings: res.pending_system_bookings,
        accepted_system_bookings: res.accepted_system_bookings,
        external_bookings: res.external_bookings,
      }, function() {
        $('#reusableModal').trigger('inventory-loaded', this.state)
      })
    })
  }
  
  loadingSpinner() {
    return (
      <div className="loading-calendar">
        <img src={BookclickerStaticData.wheelSvg}/>
        <div>Loading</div>
      </div>
    )
  }
  
  invTypeContent(invType) {
    let bookings = [];
    bookings = bookings.concat(this.state.accepted_system_bookings[invType])
    bookings = bookings.concat(this.state.pending_system_bookings[invType])
    bookings = bookings.concat(this.state.external_bookings[invType]);
    
    
    if (bookings.length || this.state.one_day_inventory[invType]) {
      
      if (this.state.remaining_inventory[invType]) {
        let numTotallyAvailableSlots = this.state.remaining_inventory[invType] - this.state.pending_system_bookings[invType].length
        
        for (let x = 0; x < numTotallyAvailableSlots; x++) {
          bookings.push({isNew: true, isNewButNotFirstAvailableNew: x > 0})
        }
      } 
      
      let html = bookings.map((booking, idx) => {
        return <CalendarDayBooking 
          key={booking.uid || idx}
          invType={invType}
          list={this.props.list}
          date={this.props.date}
          booking={booking}
          openConfirmPromoSelect={this.props.openConfirmPromoSelect}
          setRespondBooking={this.setRespondBooking.bind(this)}
          setRefundRescheduleBooking={this.setRefundRescheduleBooking.bind(this)}
          reloadData={this.loadData.bind(this)}
          isSystemBooking={booking.internal} 
          isNewButNotFirstAvailableNew={booking.isNewButNotFirstAvailableNew}
          isPending={booking["pending?"]} />
      })
      
      return (html)
    }
  }
  
  content() {
    
    let result = [];
    
    
    if (this.noBookings()) {
      if (this.inPast()) {
        result.push(
          <div key={"message"} className="calendar-day-bookings">
            <div className="calendar-day-nothing">This date has no activity</div>
          </div>
        )
      } else if (this.noInventory()) {
        result.push(
          <div key={"message"} className="calendar-day-bookings">
            <div className="calendar-day-nothing">This date has no availability</div>
          </div>
        )
      }
    }
    
    if (true) {
      result.push(
        <div key={"content"} className="calendar-day-bookings">
          {this.invTypeContent('solo')}
          {this.invTypeContent('feature')}
          {this.invTypeContent('mention')}
        </div>
      )
    }
    
    return result;
  }
  
  render() {
    
    if (this.state.respondBooking) {
      return (<RespondBookingForm booking={this.state.respondBooking} isMobile={this.props.isMobile}/>)
    } else if (this.state.refundRescheduleBooking) {
      return (<RefundRescheduleForm booking={this.state.refundRescheduleBooking} isMobile={this.props.isMobile}/>)
    } else {
      return (
        <div className="calendar-day-bookings-container">
          {this.state.loading ? this.loadingSpinner() : this.content()}
        </div>
      )
    }
    
  }
  
}