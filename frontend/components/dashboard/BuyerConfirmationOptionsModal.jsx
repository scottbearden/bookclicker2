import React from 'react';
import ReservationsApi from '../../api/ReservationsApi';


export default class BuyerConfirmationOptionsModal extends React.Component {
  
  
  constructor(props) {
    super(props);
    this.state = {
      reservation: this.props.reservation
    };
  }
  
  cantRequestConfirmationYetLabel() {
    if (this.state.reservation['send_confirmed?']) {
      return (
        <div className="not-sent-confirmation-modal-label">
          This booking has been confirmed as sent
        </div>
      )
    } else if (this.state.reservation.confirmation_requested_at) {
      return (
        <div className="not-sent-confirmation-modal-label">
          You requested confirmation on {this.state.reservation.confirmation_requested_at_pretty}
        </div>
      )
    } else if (!this.state.reservation['buyer_can_request_confirmation?']) {
      return (
        <div className="not-sent-confirmation-modal-label">
          You cannot request a confirmation until the seller has had 48 hours to confirm this promo
        </div>
      )
    }
  }
  
  cantRequestRefundYetLabel() {
    if (this.state.reservation['refunded?']) {
      return (
        <div className="not-sent-confirmation-modal-label">
          This promo has been refunded
        </div>
      )
    } else if (!this.state.reservation['refundable?']) {
      return (
        <div className="not-sent-confirmation-modal-label">
          This promo cannot be refunded
        </div>
      )
    } else if (this.state.reservation.refund_requested_at) {
      return (
        <div className="not-sent-confirmation-modal-label">
          You requested a refund on {this.state.reservation.refund_requested_at_pretty}
        </div>
      )
    } else if (this.state.reservation.confirmation_requested_at && !this.state.reservation['buyer_can_request_refund?']) {
      return (
        <div className="not-sent-confirmation-modal-label">
          You can only request a refund when a payment is on file and the seller fails to confirm a promo within 72 hours.
        </div>
      )
    }
  }
  
  sendRequest(requestType) {

    if (this.state.makingApiCall) return null;
    
    let apiCall = null;
    
    if (requestType == 'refund') {
      apiCall = ReservationsApi.requestRefund.bind(ReservationsApi, this.state.reservation.id);
    } else if (requestType == 'confirmation') {
      apiCall = ReservationsApi.requestConfirmation.bind(ReservationsApi, this.state.reservation.id);
    } else {
      return null;
    }
    
    this.setState({makingApiCall: true}, function() {
      apiCall().then(res => {
        this.setState({makingApiCall: false, reservation: res.reservation}, function() {
          this.props.updatePromo(this.state.reservation)
        })
      }, errRes => {
        let alertMessage = (errRes && errRes.responseJSON && errRes.responseJSON.message) || 'This request failed'
        this.setState({makingApiCall: false}, function() {
          alert(alertMessage)
        })
      })
    })
  }
  
  render() {
    
    let canRequestConfirmation = !this.state.makingApiCall && this.state.reservation['buyer_can_request_confirmation?'];
    let canRequestRefund = !this.state.makingApiCall && this.state.reservation['buyer_can_request_refund?']
    
    return (
      <div className="not-sent-confirmation-options">
        <h4 style={{textAlign: 'center', marginBottom: '30px'}}>What would you like to do?</h4>
        <div className="not-sent-confirmation-options-options">
          <div className="not-sent-confirmation-options-option">
            <a 
               href={"/reservations/" + this.state.reservation.id + "/info"} 
               target="_blank" 
               className="bclick-button bclick-solid-aqua-button">
              See Details
            </a>
      
          </div>
      
          <div className="not-sent-confirmation-options-option">
            <button 
               disabled={!canRequestConfirmation}
               className={"bclick-button bclick-solid-aqua-button" + (!canRequestConfirmation ? " no-hover-change" : "")}
               onClick={canRequestConfirmation ? this.sendRequest.bind(this, 'confirmation') : (e) => { e && e.preventDefault() }}>
              Request Confirmation
            </button>
            {this.cantRequestConfirmationYetLabel()}   
          </div>
      
          <div className="not-sent-confirmation-options-option">
             <button 
                disabled={!canRequestRefund}
                className={"bclick-button bclick-solid-aqua-button" + (!canRequestRefund ? " no-hover-change" : "")}
                onClick={canRequestRefund ? this.sendRequest.bind(this, 'refund') : (e) => { e && e.preventDefault() }}>
               Request Refund
             </button>
             {this.cantRequestRefundYetLabel()}
          </div>
      
        </div>
      </div>
    )
  }
  
  
}