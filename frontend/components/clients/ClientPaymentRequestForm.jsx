import React from 'react';
import UsersAssistantsApi from '../../api/UsersAssistantsApi';

export default class ClientPaymentRequestForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { payment_request: this.props.payment_request }
  }
  
  statusLabel() {
    let status = this.state.payment_request.last_known_subscription_status
    if (status) {
      return "Stripe status:  " + status.replace("_","").capitalize()
    } else {
      return <span className="not-phone">&nbsp;</span>
    }
  }
  
  payRequestIntro() {
    if (!this.state.payment_request.id) {
      return <label className="payment-request-intro">Your client will be charged this amount weekly</label>
    }
  }
  
  render() {
    return (
      <div className="assistant-payment-request-form">
        <div className="space1"></div>
      
        <div className="assistant-payment-request-form-input">
          <div className="assistant-payment-request-form-input-padding">
            <label>Weekly Rate (USD)</label>
            <input 
              type="number" 
              disabled={this.sendRequestDisabled()}
              placeholder={this.state.payment_request.pay_amount ? "" : "US Dollars"}
              className="form-control"
              onChange={this.changePayAmount.bind(this)}
              value={this.state.payment_request.pay_amount || ''} />
            {this.payRequestIntro()}
          </div>
         
        </div>
        
        <div className="assistant-payment-request-form-input">
          <div className="assistant-payment-request-form-input-padding">
            <label>{this.statusLabel()}</label>
            <input 
              type="submit"
              disabled={this.sendRequestDisabled()} 
              className={"form-control bclick-button " + this.submitStatus().css} 
              onClick={this.sendRequest.bind(this)} value={this.submitStatus().text} />
             <div className="payment-request-api-response">{this.state.sendResponse || ' '}</div>
          </div>
        </div>
        
      </div>
    )
  }
  
  sendRequestDisabled() {
    return this.state.sendingRequest || this.submitStatus().disabled
  }
  
  submitStatus() {
    let status = this.state.payment_request.status;
    if (this.state.sendingRequest) {
      return {
        text: 'Sending Request...',
        css: 'no-hover-change bclick-solid-grey-button',
        disabled: true
      }
    } else if (!status) {
      return {
        text: 'Send Payment Request',
        css: 'bclick-solid-mailchimp-gray-button',
        disabled: false
      }
    } else if (status == "Unanswered" || status == "unanswered") {
      return {
        text: 'Payment Request Sent',
        css: 'no-hover-change bclick-solid-deep-blue-button',
        disabled: true
      }
    } else if (status == "Accepted" || status == "accepted") {
      return {
        text: 'Payment Request Accepted',
        css: 'no-hover-change bclick-solid-notification-button-button',
        disabled: true
      }
    } else if (status == 'Declined' || status == "declined") {
      return {
        text: 'Payment Request Declined',
        css: 'no-hover-change bclick-solid-dark-red-button',
        disabled: true
      }
    } else if (status == "Cancelled" || status == "cancelled") {
      return {
        text: 'Cancelled',
        css: 'no-hover-change bclick-solid-dark-red-button',
        disabled: true
      }
    }
  }
  
  changePayAmount(event) {
    let { payment_request } = this.state;
    payment_request.pay_amount = event.target.value;
    this.setState({payment_request, sendResponse: null})
  }
  
  sendRequest(event) {
    event.preventDefault()
    var that = this
    if (!this.sendRequestDisabled()) {
      this.setState({sendingRequest: true}, function() {
        UsersAssistantsApi.createPaymentRequest(
          this.props.connectionId,
          this.state.payment_request.pay_amount
        ).then(res => {
          this.setState({
            sendingRequest: false,
            sendResponse: <span style={{color: '#51C7B7'}}>{res.message || 'Your request was sent!'}</span>
          }, function() {
            this.props.propogateState({connection: res.connection})
          })
        }, errRes => {
          let message = errRes && errRes.responseJSON && errRes.responseJSON.message
          this.setState({
            sendingRequest: false,
            sendResponse: <span style={{color: '#CD201F'}} dangerouslySetInnerHTML={{__html: (message || 'Your request failed') }}></span>
          })
        })
      })
    }
  }
  
  
}