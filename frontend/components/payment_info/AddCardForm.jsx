import React from 'react';
import CardData from './CardData';
import { grabCsrfToken } from '../../ext/functions';

export default class AddCardForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      cardData: {}
    };
  }
  
  componentDidMount() {
    let style = { base: { fontSize: '12px', lineHeight: '20px' } };
    let card = stripeElements.create('card', {style: style});
    
    if (!this.props.stripeSetupIntent || !this.props.stripeSetupIntent.client_secret) {
      alert('An error occured loading the payment info form.  Please reload this page.');
      return;
    }

    this.setState({card, stripeSetupClientSecret: this.props.stripeSetupIntent.client_secret }, function() {
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
  
  submitPayment(event) {
    event.preventDefault();
    if (this.state.submittingCardInfo) return null;
    var that = this;
    this.setState({submittingCardInfo: true}, function() {

      stripe.confirmCardSetup(
        this.state.stripeSetupClientSecret,
        {
          payment_method: {
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
      ).then(function(result) {
        if (result.error) {
          var errorElement = document.getElementById('card-errors');
          errorElement.textContent = result.error.message;
          that.setState({submittingCardInfo: false})
        } else {
          that.submitPaymentMethod(result);
        }
      });
    })
    
  }

  submitPaymentMethod(result) {
    var form = document.getElementById('payment-form');

    var paymentMethodHiddenInput = document.createElement('input');
    paymentMethodHiddenInput.setAttribute('type', 'hidden');
    paymentMethodHiddenInput.setAttribute('name', 'payment_method');
    paymentMethodHiddenInput.setAttribute('value', result.setupIntent.payment_method);
    form.appendChild(paymentMethodHiddenInput);

    var setupIntentHiddenInput = document.createElement('input');
    setupIntentHiddenInput.setAttribute('type', 'hidden');
    setupIntentHiddenInput.setAttribute('name', 'setup_intent_id');
    setupIntentHiddenInput.setAttribute('value', result.setupIntent.id);
    form.appendChild(setupIntentHiddenInput);
    form.submit();
  }
  
  render() {
    return (
      <div id="payment-form-container" style={{marginTop: '0px'}}>
        <form action="/payment_infos" method="post" id="payment-form" onSubmit={e => e.preventDefault()}>
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
          <input type='hidden' id='stripe-setup-intent-client-secret' name='stripe_setup_intent_client_secret' value={this.props.stripeSetupIntent.client_secret} />
          <input type='hidden' id='stripe-setup-intent-id' name='stripe_setup_intent_id' value={this.props.stripeSetupIntent.id} />
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
                  Credit or Debit Card 
                </div>
              </div>
              
              <div className="payment-form-info-item-container right">
                <div className="payment-form-info-item">
                  New Card
                </div>
              </div>
            </div>
      
            <CardData 
             cardData={this.state.cardData}
             changeCardData={this.changeCardData.bind(this)}
             changeCardAddressCountry={this.changeCardAddressCountry.bind(this)}/>
            
          
            <div id="card-element"></div>
            <div id="card-errors" role="alert"></div>
          </div>

          <div className="form-row">
            <div id="card-agreement">
              By submitting this info, I authorize BookClicker to send instructions to the financial institution that issued my card to take payments from my card account in accordance with the terms of my agreement with you.
            </div>
          </div>
             
          <button 
            type="button"
            onClick={this.submitPayment.bind(this)} 
            disabled={this.state.submittingCardInfo}
            className={"bclick-button bclick-solid-notification-button-button" + (this.state.submittingCardInfo ? " no-hover-change" : "")}>
            
            Add Card Info
          </button>
        </form>
      </div>
    )
  }
  
}
