import React from 'react';
import ExternalReservationsApi from '../../api/ExternalReservationsApi';
import { hex } from '../../ext/functions';


export default class CalendarDayBooking extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      book_owner_name: this.props.booking.book_owner_name,
      book_owner_email: this.props.booking.book_owner_email,
      book_title: this.props.booking.book_title,
      book_link: this.props.booking.book_link,
      error: null,
      lastChangeAt: null
    }
  }
  
  badData() {
    return this.props.isSystemBooking && jQuery.isEmptyObject(this.props.booking.book);
  }
    
  render () {
    if (!this.badData()) {
      return (
        <div className="calendar-day-inv-type-section">
          {this.inventoryTypeHeader()}
          {this.inventoryInputs()}
        </div>
      )
    }
  }
  
  inventoryTypeHeader() {
    return (
      <div className="calendar-day-bookings-inv-type-header">
        {this.props.invType.capitalize()}
      </div>
    )
  }
  
  inventoryError() {
    return (
      <div className="calendar-day-bookings-error">
        {this.state.error}
      </div>
    )
  }
  
  changeBookTitle(event) {
    let allowedSaveHash = hex(10);
    this.setState({
      book_title: event.target ? event.target.value : null,
      lastChangeAt: Date.now(),
      goingToSave: true,
      allowedSaveHash
    })
    this.throttleSave(allowedSaveHash)
  }
  
  changeBookLink(event) {
    let allowedSaveHash = hex(10);
    this.setState({
      book_link: event.target ? event.target.value : null,
      lastChangeAt: Date.now(),
      goingToSave: true,
      allowedSaveHash
    })
    this.throttleSave(allowedSaveHash)
  }
  
  changeAuthorName(event) {
    let allowedSaveHash = hex(10);
    this.setState({
      book_owner_name: event.target ? event.target.value : null, 
      lastChangeAt: Date.now(), 
      goingToSave: true,
      allowedSaveHash
    })
    this.throttleSave(allowedSaveHash)
  }
  
  changeAuthorEmail(event) {
    let allowedSaveHash = hex(10);
    this.setState({
      book_owner_email: event.target ? event.target.value : null, 
      lastChangeAt: Date.now(),
      goingToSave: true,
      allowedSaveHash
    })
    this.throttleSave(allowedSaveHash)
  }
  
  enoughThrottleTimeHasPassed() {
    return !this.state.lastChangeAt || Date.now() - this.state.lastChangeAt > 900
  }
  
  throttleSave(allowedSaveHash) {
    var that = this;
    setTimeout(function() {
      if (that.state.allowedSaveHash !== allowedSaveHash) {
        return null
      } else if (that.enoughThrottleTimeHasPassed()) {
        that.setState({goingToSave: false}, that.saveExternalBooking.bind(that))
      } else {
        that.throttleSave(allowedSaveHash)
      }
    }, 1100)
  }
  
  saveExternalBooking(noim) {
    
    let initialError = null;
    
    if (this.state.saving) {
      return false
    } else if (this.state.book_owner_email && this.invalidBookOwnerEmail()) {
      initialError = 'email'
    } 
    
    let jsonData = {
      list_id: this.props.list.id,
      inv_type: this.props.invType,
      date: this.props.date,
      book_owner_name: this.state.book_owner_name,
      book_owner_email: this.state.book_owner_email,
      book_title: this.state.book_title,
      book_link: this.state.book_link,
      confirm_send: false
    }
    
    this.setState({saving: true, allowedSaveHash: null, error: initialError}, function() {
      var that = this;
      if (this.props.booking.id) {
        ExternalReservationsApi.update(this.props.booking.id, jsonData).then(
          that.onSaveExternalBooking.bind(that), 
          that.onSaveExternalBookingError.bind(that))
      } else {
        ExternalReservationsApi.create(jsonData).then(
          that.onSaveExternalBooking.bind(that), 
          that.onSaveExternalBookingError.bind(that))
      }
    })
  }
  
  invalidBookOwnerEmail() {
    return !this.state.book_owner_email || !this.state.book_owner_email.match(/^[^@\s]+@([^@\s]+\.)+[^@\s]+$/)
  }
  
  emailError() {
    return this.state.error && this.state.error.match(/email/)
  }
  
  promptValidEmail(delay) {
    var that = this;
    setTimeout(function() {
      if (that.props.booking.id && that.invalidBookOwnerEmail() && !that.state.sawPromptValidEmail) {
        that.setState({error: 'email', sawPromptValidEmail: true})
      } else {
        that.setState({error: null})
      }
    }, delay)
  }
  
  onSaveExternalBooking() {
    this.setState({error: null, saving: false}, function() {
      this.props.reloadData()
    })
  }
  
  onSaveExternalBookingError(response) {
    let error = response.responseJSON ? response.responseJSON.error : 'Your data could not be saved.'
    this.setState({error: error, saving: false});
  }
  
  openRespondForm() {
    this.props.setRespondBooking(this.props.booking);
  }
  
  openRescheduleOrRefundForm() {
    this.props.setRefundRescheduleBooking(this.props.booking);
  }
  
  openConfirmPromoWrapperMethod() {
    if (this.state.saving || this.state.goingToSave || this.state.openingConfirmPromos) {
      return null;
    }
    this.setState({ openingConfirmPromos: true }, function() {
      let resType = this.props.isSystemBooking ? 'Reservation' : 'ExternalReservation';
      let resId = this.props.booking.id;
      this.props.openConfirmPromoSelect(resId, resType)
    })
  }
  
  systemBookingLinkAttrs() {
    let label = null, action = null, cssClass = "";
    if (this.props.isPending) {
      label = "Respond"
      action = this.openRespondForm.bind(this);
    } else if (this.props.booking["send_confirmed?"]) {
      label = "Sent!";
      cssClass = "bclick-hollow-teal-button";
      action = this.openConfirmPromoWrapperMethod.bind(this);
    } else if (this.props.booking["needs_confirm?"]) {
      label = [<span key='a' className="not-phone">Confirm Send</span>, <span key='b' className="phone">Confirm</span>];
      action = this.openConfirmPromoWrapperMethod.bind(this);
    } else {
      label = "Edit";
      action = this.openRescheduleOrRefundForm.bind(this);
    }
    return { label, action, cssClass }
  }
  
  externalBookingLinkAttrs() {
    let label = null, action = null, cssClass = "";
    if (this.props.booking["send_confirmed?"]) {
      label = "Sent!";
      cssClass = "bclick-hollow-teal-button";
      action = this.openConfirmPromoWrapperMethod.bind(this);
    } else if (this.props.booking["needs_confirm?"]) {
      label = [<span key='c' className="not-phone">Confirm Send</span>, <span key='d' className="phone">Confirm</span>];
      action = this.openConfirmPromoWrapperMethod.bind(this);
    } else {
      label = null
      action = null;
    }
    return { label, action, cssClass }
  }
    
  inventoryInputs() {
    let inputs = []
    if (this.props.isSystemBooking) {
      inputs.push(
        <div key={'author'} className={"calendar-day-bookings-form-input-wrapper" + (this.props.isPending ? " system-pending" : " system-accepted") }>
          <a href={'/reservations/' + this.props.booking.id + '/info'} target="_blank">
           <input type="text" 
             disabled={true}
             placeholder="No Author Name Provided" 
             className={this.props.booking.book.author ? '' : 'empty'}
             value={this.props.booking.book.author || ''}/>
          </a>
        </div>
      )
      inputs.push(
        <div  key={'title'} className={"calendar-day-bookings-form-input-wrapper" + (this.props.isPending ? " system-pending" : " system-accepted") }>
          <a href={'/reservations/' + this.props.booking.id + '/info'} target="_blank">
           <input type="text"
             disabled={true}
             placeholder="No Book Title Provided" 
             className={this.props.booking.book.title ? '' : 'empty'}
             value={this.props.booking.book.title || ''}/>
          </a>
        </div>
      )
      
    } else {
      inputs.push(
        <div key={'author'} className={"calendar-day-bookings-form-input-wrapper external" + (this.props.booking["send_confirmed?"] ? " send-confirmed" : "")}>
           <input type="text" 
             placeholder="Author Name"
             disabled={this.props.isNewButNotFirstAvailableNew}
             onFocus={e => this.setState({lastChangeAt: Date.now() + 400}) }
             onChange={this.changeAuthorName.bind(this)} 
             value={this.state.book_owner_name || ''}/>
        </div>
      )
      inputs.push(
        <div key={'email'} className={"calendar-day-bookings-form-input-wrapper external" + (this.emailError() ? " email-error" : "") + (this.props.booking["send_confirmed?"] ? " send-confirmed" : "") }>
           <input type="email" 
             placeholder={this.emailError() ? 'Please enter a valid email' : 'Author Email'}
             disabled={this.props.isNewButNotFirstAvailableNew}
             onMouseOver={this.promptValidEmail.bind(this, 200)}
             onFocus={e => this.setState({lastChangeAt: Date.now() + 400}) }
             onChange={this.changeAuthorEmail.bind(this)}
             value={this.state.book_owner_email || ''}/>
        </div>
      )
      
    }
    
    let linkAttrs = this.props.isSystemBooking ? this.systemBookingLinkAttrs() : this.externalBookingLinkAttrs()
    
    if (linkAttrs.label) {
      inputs.push(
        <div key={'link'} className={"calendar-day-bookings-form-link-wrapper"}>
           <a
             disabled={this.state.saving || this.state.openingConfirmPromos}
             className={'bclick-button' + ' ' + (linkAttrs.cssClass || 'bclick-hollow-mailchimp-gray-button')}
             onClick={linkAttrs.action}>{this.state.saving ? 'Saving...' : linkAttrs.label}</a>
        </div>
      )
    }
    
    if (!this.props.isSystemBooking) {
      inputs.push(<br key={'br1'}/>)
      inputs.push(
        <div key={'title'} className={"calendar-day-bookings-form-input-wrapper external"}>
           <input type="text" 
             placeholder="Book Title"
             disabled={this.props.isNewButNotFirstAvailableNew}
             onFocus={e => this.setState({lastChangeAt: Date.now() + 400}) }
             onChange={this.changeBookTitle.bind(this)} 
             value={this.state.book_title || ''}/>
        </div>
      )
      inputs.push(
        <div key={'bookLink'} className={"calendar-day-bookings-form-input-wrapper external"}>
           <input type="text" 
             placeholder="Book Link"
             disabled={this.props.isNewButNotFirstAvailableNew}
             onFocus={e => this.setState({lastChangeAt: Date.now() + 400}) }
             onChange={this.changeBookLink.bind(this)} 
             value={this.state.book_link || ''}/>
        </div>
      )
    }
    
    return (
      <form className="calendar-day-bookings-form">
        {inputs}
      </form>
    )
  }

  
  
}