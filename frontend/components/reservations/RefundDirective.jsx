import React from 'react';
import ReservationsApi from '../../api/ReservationsApi';
export default class RefundDirective extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { }
  }
  
  refundPaymentButton() {
    let canRefund = this.props.refund_directive.possible;
    
    return (
      <div className="info-page-accept-decline-action">
         <a 
          href={canRefund ? ("/reservations/" + this.props.reservation.id + "/refund") : null}
          disabled={!canRefund}
          className={"bclick-button bclick-solid-youtube-red-button" + (canRefund ? "" : " no-hover-change")}>
          {this.buttonText()}
         </a>
      </div>
    )
  }
  
  buttonCss() {
    let result = {margin: '30px'}
    if (!this.props.refund_directive.possible) {
      result.opacity = '0.7'
    }
    return result;
  }
  
  buttonText() {
    if (!this.props.refund_directive.possible) {
      return  "Refund not available"
    } else if (this.props.refund_directive.amount) {
      return  "Refund payment of $" + this.props.refund_directive.amount
    } else {
      return  "Refund payment"
    }
  }
  
  render() {
    return !this.props.refund_directive ? null : (
      <div className="connect-with-stripe-container" style={this.buttonCss()}>
        {this.refundPaymentButton()}
      </div>
    )
  }
}