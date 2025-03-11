import React from 'react';
import ReservationsApi from '../../api/ReservationsApi';
export default class AcceptDeclineDirective extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      error: null,
      success: null,
      reply_message: this.props.reservation.reply_message,
      reservation: this.props.reservation,
      makingApiCall: false
    };
  }
  
  changeReplyMessage(event) {
    this.setState({reply_message: event.target.value})
  }
  
  makeApiCall(method) {
    if (this.state.makingApiCall || false) {
      return null;
    }
    
    let apiCall = null;
    if (method == 'decline') {
      apiCall = ReservationsApi.decline.bind(ReservationsApi, this.props.reservation.id, this.state.reply_message)
    } else if (method == 'accept') {
      apiCall = ReservationsApi.accept.bind(ReservationsApi, this.props.reservation.id, this.state.reply_message)
    } else {
      alert('Something went wrong');
      return null;
    }
    
    
    var that = this;
    this.setState({makingApiCall: true}, function() {
      apiCall().then(res => {
        that.setState({reservation: res.reservation, error: null, success: res.message}, function() {
          that.props.propogateState({stripe_directive: res.stripe_directive})
        })
      }, errRes => {
        let newState = { error: 'Action failed' };
        if (errRes.responseJSON) {
          newState['error'] = errRes.responseJSON.message;
          if (errRes.responseJSON.reservation) {
            newState['reservation'] = errRes.responseJSON.reservation
          }
        }
        this.setState(newState)
      })
    })
  	
  }
  
  linksDisabled() {
    return (this.state.makingApiCall || !this.state.reservation['pending?'])
  }
  
  acceptPaymentButton() {
    let actionDisabled = this.linksDisabled() || !this.state.reservation['payment_offer?'];
    let happened = this.state.reservation['payment_offer_accepted?'];
    return (
      <div className="info-page-accept-decline-action left">
         <button 
          disabled={actionDisabled}
          onClick={actionDisabled ? (e) => { e.preventDefault() } : this.makeApiCall.bind(this, 'accept')}
          className={"bclick-button bclick-solid-mailchimp-gray-button" + (actionDisabled ? " no-hover-change" : "") + (happened ? " darken" : "")}>
          {happened ? "Accepted" : "Accept"}
         </button>
      </div>
    )
  }
  
  viewSwapsLink() {
    let actionDisabled = this.linksDisabled() || !this.state.reservation['swap_offer?']
    let happened = this.state.reservation['swap_offer_accepted?'];
    return (
      <div className="info-page-accept-decline-action middle">
         <a 
          target="_blank"
          disabled={actionDisabled}
          href={actionDisabled ? null : ("/swap_calendar/" + this.props.reservation.id)}
          className={"bclick-button bclick-solid-mailchimp-gray-button" + (actionDisabled ? " no-hover-change" : "") + (happened ? " darken" : "")}>
            {happened ? "Swapped" : "Swap"}
         </a>
      </div>
    )
  }
  
  declinePaymentButton() {
    let actionDisabled = this.linksDisabled();
    let happened = this.state.reservation['declined?'];
    return (
      <div className="info-page-accept-decline-action right">
         <button 
          disabled={actionDisabled}
          onClick={actionDisabled ? (e) => { e.preventDefault() } : this.makeApiCall.bind(this, 'decline')}
          className={"bclick-button bclick-solid-dark-red-button" + (actionDisabled ? " no-hover-change" : "") + (happened ? " darken" : "")}>
            {happened ? "Declined" : "Decline"}
         </button>
      </div>
    )
  }
  
  replyMessageInput() {
    
    if (!this.props.reservation['pending?'] && !this.state.reservation.reply_message) {
      //page was loaded with reply already given and they didnt include a reply
      return null;
    }
    
    let replyTextDisabled = this.linksDisabled()
    return (
      <div className="info-page-accept-decline-reply">
        <textarea 
          placeholder={!this.state.reply_message ? "Enter an optional reply message" : null}
          disabled={replyTextDisabled}
          className="form-control" 
          value={this.state.reply_message || ''} 
          onChange={this.changeReplyMessage.bind(this)} />
      </div>
    )
  }
  
  render() {
    return !this.props.accept_decline_directive ? null :  (
      <div className="connect-with-stripe-container info-page-accept-decline-buttons">
        {this.replyMessageInput()}
        {this.acceptPaymentButton()}
        {this.viewSwapsLink()}
        {this.declinePaymentButton()}
        <div className="info-page-accept-decline-error">
          {this.state.error}
        </div>
        <div className="info-page-accept-decline-success">
          {this.state.success}
        </div>
      </div>
    )
  }
}