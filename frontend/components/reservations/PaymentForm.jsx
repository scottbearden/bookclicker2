import React from 'react';
import { grabCsrfToken } from '../../ext/functions';
import PaymentInfoApi from '../../api/PaymentInfoApi';
import CardData from '../payment_info/CardData';

export default class PaymentForm extends React.Component {
  
  constructor(props) {
    super(props);
    let default_payment_source = this.props.customer ? this.props.customer.default_source : null;
    this.state = { 
      isPaid: this.props.reservation["paid?"],
      currentlySubmittingPayment: false,
      default_source: default_payment_source,
      cardData: {},
      stripeConnect: Stripe(BookclickerStaticData.stripePublishableKey, {
        stripeAccount: this.props.seller_stripe_acct_id
      })
    };
  }
  
  changeCardAddressCountry(selection) {
    let { cardData } = this.state;
    cardData.address_country = selection ? selection.value : null;
    this.setState({cardData});
  }
  
  changeCardData(field, event) {
    let { cardData } = this.state;
    cardData[field] = event ? event.target.value : null;
    this.setState({cardData});
  }
  
  componentDidMount() {
    if (this.state.isPaid) {
     return null; 
    }

    if (!this.props.payment_intent || !this.props.payment_intent.client_secret) {
      alert('An error occured.  Please reload this page.');
      return;
    }
    
    if (this.props.customer) {
      PaymentInfoApi.getDefaultSource().then(res => {
        this.setState({default_source: res.default_source})
      }, errRes => {
        this.setState({default_source: null})
      })
    }
    
    let style = { base: { fontSize: '12px', lineHeight: '20px' } };
    let card = this.state.stripeConnect.elements().create('card', {style: style});
    
    this.setState({card}, function() {
      this.state.card.mount('#card-element');
      this.state.card.addEventListener('change', function(event) {
        $('#one-time-source-errors').html(event.error ? event.error.message : '')
      });
    })
  }

  paymentMethod(isDefaultSource) {
    if (isDefaultSource) {
      return this.props.cloned_payment_method;
    } else {
      return {
        card: this.state.card,
        billing_details: {
          name: this.state.cardData.name,
          address: {
            city: this.state.cardData.address_city,
            country: this.state.cardData.address_country,
            line1: this.state.cardData.address_line1,
            line2: this.state.cardData.address_line2,
            postal_code: this.state.cardData.address_zip,
            state: this.state.cardData.address_state
          }
        }
      }
    }
  }
  
  submitPayment(isDefaultSource, event) {
    event.preventDefault();
    if (this.state.currentlySubmittingPayment) return null;
    var that = this;
    that.setState({currentlySubmittingPayment: true}, function() {
      that.state.stripeConnect.confirmCardPayment(
        that.props.payment_intent.client_secret,
        {
          payment_method: that.paymentMethod(isDefaultSource)
        }
      ).then(function(result) {
        var errorDivSelector = isDefaultSource ? '#default-source-errors' : '#one-time-source-errors'
        if (result.error) {
          $(errorDivSelector).html(result.error.message)
          that.setState({currentlySubmittingPayment: false})
        } else {
          $(errorDivSelector).css({color: 'darkgreen'})
          $(errorDivSelector).html('Submitting payment. This may take a minute....')
          var form = document.getElementById('payment-form');
          var paymentIntentHiddenInput = document.createElement('input');
          paymentIntentHiddenInput.setAttribute('type', 'hidden');
          paymentIntentHiddenInput.setAttribute('name', 'stripe_payment_intent_id');
          paymentIntentHiddenInput.setAttribute('value', that.props.payment_intent.id);
          form.appendChild(paymentIntentHiddenInput);
          form.submit();
        }
      });
    })
  }
  
  paymentSourcePayButtonText() {
    let brand = this.props.customer.default_source.brand;
    let last4 = this.props.customer.default_source.last4;
    let cardText = brand + " **" + last4;
    return <span>Pay ${this.props.reservation.payment_offer_total} With Your {cardText}</span>
  }
  
  useDefaultPaymentSourceButton() {
    if (this.props.customer && this.props.customer.default_source && this.props.cloned_payment_method) {
      return (
        <div>
          <div className="use-default-payment">
            <button onClick={this.submitPayment.bind(this, true)} className="bclick-button bclick-solid-blue-button launch-stripe-js-button">
              {this.paymentSourcePayButtonText()}
            </button>
          </div>
          <div id="default-source-errors" role="alert"></div>     
        </div>
      )
    }
  }
  
  render() {
    if (this.state.isPaid) {
      return (
        <h2>{"You've paid!"}</h2>   
      )
    }
    if (!this.props.reservation.payment_offer_total) {
      return (
        <h2>We cannot locate the agreed price of this booking.</h2>
      )
    }


    return (
      <div>
        {this.useDefaultPaymentSourceButton()}
        <div id="payment-form-container">
          <form action="/stripe/charge_buyer" method="post" id="payment-form" onSubmit={e => e.preventDefault()}>
            <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
            <input type='hidden' name='reservation_id' value={this.props.reservation.id} />
            <div className="form-row">
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
                    One-time Payment Details
                  </div>
                </div>
              
                <div className="payment-form-info-item-container right">
                  <div className="payment-form-info-item">
                    Amt - ${this.props.reservation.payment_offer_total}
                  </div>
                </div>
              </div>
                    
             <CardData 
              cardData={this.state.cardData}
              changeCardData={this.changeCardData.bind(this)}
              changeCardAddressCountry={this.changeCardAddressCountry.bind(this)}/>
          
              <div id="card-element"></div>
              <div id="one-time-source-errors" role="alert"></div>
            </div>

            <div className="form-row">
              <div id="card-agreement">
                This card info will not be saved.  Use the Payment Info page to save card info.
              </div>
            </div>

            <button 
              className="launch-stripe-js-button" 
              type="button"
              onClick={this.submitPayment.bind(this, false)} 
              disabled={this.state.currentlySubmittingPayment}
              className={"bclick-button bclick-solid-notification-button-button" + (this.state.currentlySubmittingPayment ? " no-hover-change" : "")}>
            
              Pay ${this.props.reservation.payment_offer_total}
            </button>
          </form>
        </div>
      </div>
    )
  }
  
}
