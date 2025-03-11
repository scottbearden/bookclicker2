import React from 'react';
import { grabCsrfToken } from '../../ext/functions';

export default class AssistantPaymentRequestAcceptForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      currentlySubmittingPayment: false
    };
  }
  
  componentDidMount() {
    let style = { base: { fontSize: '12px', lineHeight: '20px' } };
    let card = stripeElements.create('card', {style: style});
    
    this.setState({card}, function() {
      this.state.card.mount('#card-element');
      this.state.card.addEventListener('change', function(event) {
        var displayError = document.getElementById('card-errors');
        if (event.error) {
          displayError.textContent = event.error.message;
        } else {
          displayError.textContent = '';
        }
      });
    })
  }
  
  submitPayment(event) {
    
    event.preventDefault();
    
    if (this.state.currentlySubmittingPayment) return null;
    
    var that = this;
    
    this.setState({currentlySubmittingPayment: true}, function() {
      stripe.createToken(that.state.card).then(function(result) {
        if (result.error) {
          var errorElement = document.getElementById('card-errors');
          errorElement.textContent = result.error.message;
          that.setState({currentlySubmittingPayment: false})
        } else {
          that.stripeTokenHandler(result.token);
        }
      });
    })
    
  }
  
  stripeTokenHandler(token) {
    var form = document.getElementById('payment-form');
    var hiddenInput = document.createElement('input');
    hiddenInput.setAttribute('type', 'hidden');
    hiddenInput.setAttribute('name', 'stripeToken');
    hiddenInput.setAttribute('value', token.id);
    form.appendChild(hiddenInput);
    form.submit();
  }
  
  render() {
    if (!this.props.payment_request.id || !this.props.users_assistant.id) {
      return <h3>There is an error on this page.  Please report to application owner</h3>
    }
    
    let notice = null;
    if (this.props.payment_request['accepted?']) {
      notice = (
        <h4 style={{color: 'blue'}}>This payment request has already been accepted.  You still may update payment information below.</h4>
      )
    }
    
    return (
      <div id="payment-form-container">
      <form action="/stripe/begin_assistant_payment_plan" method="post" id="payment-form" onSubmit={e => e.preventDefault()}>
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
          <input type='hidden' name='assistant_payment_request_id' value={this.props.payment_request.id} />
          <input type='hidden' name='users_assistant_id' value={this.props.users_assistant.id} />
          <div className="form-row">
          
            {notice}
            <div className="payment-form-info">
              <div className="payment-form-info-item-container left">
                <div className="payment-form-info-item">
                  <div className="powered-by-strip-logo">
                    <img src={BookclickerStaticData.poweredByStripeLogo}/> 
                  </div>
                </div>
              </div>
            
              <div className="payment-form-info-item-container center">
                <div className="payment-form-info-item">
                  Credit or Debit Card 
                </div>
              </div>
              
              <div className="payment-form-info-item-container right">
                <div className="payment-form-info-item">
                  Amt - ${this.props.payment_request.pay_amount} Weekly
                </div>
              </div>
            </div>
          
            <div id="card-element"></div>
            <div id="card-errors" role="alert"></div>
          </div>
          <button 
            className="launch-stripe-js-button" 
            type="button" 
            onClick={this.submitPayment.bind(this)} 
            disabled={this.state.currentlySubmittingPayment}
            className={"bclick-button bclick-solid-notification-button-button" + (this.state.currentlySubmittingPayment ? " no-hover-change" : "")}
            >
            
            {this.props.payment_request['accepted?'] ? "Update Payment Info" : "Begin Payment Plan"}
          </button>
        </form>
      </div>
    )
  }
  
}