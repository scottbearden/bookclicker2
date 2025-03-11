import React from 'react';
import Slider, { Range } from 'rc-slider';
import { injectAuthenticityToken, pick } from '../../ext/functions';
import { iOS } from '../../ext/userAgent';
import Select from 'react-select';
import MyListsApi from '../../api/MyListsApi';
import OfferBookInfo from './OfferBookInfo';

export default class RespondBookingForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      offerPayment: this.props.booking.payment_offer, 
      offerSwap: this.props.booking.swap_offer,
      swap_offer_solo: this.props.booking.swap_offer_solo,
      swap_offer_feature: this.props.booking.swap_offer_feature,
      swap_offer_mention: this.props.booking.swap_offer_mention,
      formError: null, 
      premiumOffer: this.props.booking.premium || 0 };
  } 

  componentDidUpdate() {
    injectAuthenticityToken($, '.form-authenticity-token');
  }

  componentDidMount() {
    MyListsApi.getMyLists(false).then(res => {
      this.setState({buyerLists: res.lists})
    })
    $('#reusableModal .modal-footer').html('')
  }

  buyerSwapListOptions() {
    return this.state.buyerLists.map(list => {
      return { value: list.id, label: list.adopted_pen_name }
    })
  }

  buyerPremiumOptions() {
    let result = []
    for (let x = 1; x <= 200; x++) {
      result.push({label: ('$' + x.toString()), value: x})
    }
    return result;
  }

  swapOfferInvTypes() {
    if (this.state.offerSwap) {

      let result = [];
      let allInvTypes = ['solo', 'feature', 'mention'];
      result.push(
        <div className="offer-in-exchange-message" key="swapForMessage">
          Swapping for...
        </div>
      )
      allInvTypes.forEach(invType => {
        result.push(
          <div className="swap-offer-list-inv-type-1" key={invType} style={{width: '33%'}}>
            <div className="buyer-swap-inv-type-label">{invType.capitalize()}</div>
            <input type="checkbox"
               value="1"
               disabled={true}
               defaultChecked={this.state["swap_offer_" + invType]} />
          </div>
        )
      });
      return result;
    }
    
  }
  
  round5(x) {
    return Math.ceil(x/5)*5;
  }

  swapOfferSelectedInvTypes() {
    let result = [];
    if (this.state.swap_offer_solo) {
      result.push('solo');
    }
    if (this.state.swap_offer_feature) {
      result.push('feature')
    }
    if (this.state.swap_offer_mention) {
      result.push('mention')
    }
    return result;
  }

  clearSwapOfferInvSelections() {
    this.setState({
      swap_offer_solo: false,
      swap_offer_feature: false,
      swap_offer_mention: false
    })
  }
  
  basePrice() {
    return this.props.booking.price || 0;
  }
  
  zeroPremiumPrice(event) {
    this.setState({premiumOffer: 0})
  }

  basePricePlusPremium() {
    return parseInt((this.state.premiumOffer || 0) + this.basePrice());
  }
  
  paymentOfferSliderMarks() {
    let result = {}
    result[this.basePrice()] = {
      style: {
        color: 'grey'
      }
    }
    return result;
  }
  
  acceptPaymentLink() {
    return (
      <div className={"respond-button" + (this.props.booking.payment_offer ? "" : " disabled")}>
        <a 
          onClick={e => { !this.props.booking.payment_offer ? e.preventDefault() : null }}
          href={"/reservations/" + this.props.booking.id + "/accept"}
          disabled={!this.props.booking.payment_offer}
          className="bclick-button bclick-solid-mailchimp-gray-button">Accept Payment</a>
      </div>
    )
  }
  
  acceptSwapLink() {
    return (
      <div className={"respond-button" + (this.props.booking.swap_offer ? "" : " disabled")}>
        <a 
          onClick={e => { !this.props.booking.swap_offer ? e.preventDefault() : null }}
          href={"/swap_calendar/" + this.props.booking.id}
          target={this.props.booking.swap_offer ? "_blank" : ""}
          disabled={!this.props.booking.swap_offer}
          className="bclick-button bclick-solid-mailchimp-gray-button">View Swaps</a>
      </div>
    )
  }
  
  declineLink(center) {
    return (
      <div className={"respond-button" + (center ? " center" : "")}>
        <a 
          href={"/reservations/" + this.props.booking.id + "/decline"}
          className="bclick-button bclick-solid-dark-red-button">Decline</a>
      </div>
    )
  }
  
  render() {
    return (
      <div className="booking-form respond-booking-form">
        <div className="booking-form-title">
          Respond To {this.props.booking.inv_type.capitalize()} Offer
          <div style={{fontSize: '5px'}}>&nbsp;</div>
          <OfferBookInfo booking={this.props.booking}/>
        </div>
        
        <form action='#' method='POST' onSubmit={e => e.preventDefault()}>

          <div className={"payment-or-swap-container"}>
            <div className={(iOS() ? "ios offer-container" : "offer-container") + (!this.state.offerPayment ? " not-offered" : "")}>
              <div className="payment-checkbox-container">
                <input type="checkbox"
                  value="1"
                  disabled={!this.state.offerPayment}
                  onChange={() => {}}
                  checked={this.state.offerPayment} />
                <div className="offer-type">Payment Offer</div>
              </div>

              <div className={"payment-offer-content" + (this.state.offerPayment ? "" : " disabled")}>
                
                <span className={"payment-offer-slider-total"}>
                  ${this.basePricePlusPremium()}
                </span>
                
                <input 
                  type="hidden" 
                  value={this.state.premiumOffer || ''} />
              
                <Slider 
                  min={0} 
                  max={this.basePrice() ? this.round5(this.basePrice())*2 : 250}
                  step={5} 
                  handleStyle={{
                    height: 28,
                    width: 28,
                    marginLeft: -14,
                    marginTop: -14,
                  }}
                  minimumTrackStyle={{ backgroundColor: 'darkgreen' }}
                  marks={this.paymentOfferSliderMarks()}
                  disabled={true}
                  defaultValue={this.basePricePlusPremium()} />
                  
                <a className='base-price'><span>Original Price: ${this.basePrice()}</span></a>
                
              </div>
              
              <div className="respond-buttons phone">
                {this.acceptPaymentLink()}
              </div>
              
            </div>

            <div className={(iOS() ? "ios offer-container" : "offer-container") + (!this.state.offerSwap ? " not-offered" : "")}>
              <div className="swap-checkbox-container">
                <input type="checkbox"
                  value="1"
                  disabled={!this.state.offerSwap}
                  onChange={() => {}}
                  checked={this.state.offerSwap} />
                <div className="offer-type">Swap Offer</div>
              </div>

              <div className="swap-offer-content">
                <div className="swap-offer-list-select">
                  <Select
                    clearable={false}
                    searchable={false}
                    disabled={true}
                    value={1}
                    options={[
                      {
                        value: 1, 
                        label: (this.props.booking.swap_offer_list ? this.props.booking.swap_offer_list.adopted_pen_name : " --- ")
                      }
                    ]} />
                </div>

                <div className="swap-offer-list-inv-type">

                  {this.swapOfferInvTypes()}

                </div>
                
              </div>
              
              <div className="respond-buttons phone">
                {this.acceptSwapLink()}
              </div>

            </div>
            
            <div className={(iOS() ? "ios offer-container phone" : "offer-container phone")}>
              <div className="swap-checkbox-container">
                <div className="offer-type">Decline Offer</div>
              </div>
              
              <div className="respond-buttons phone">
                {this.declineLink(false)}
              </div>
            </div>

          </div>
          
          <div className="respond-buttons not-phone">
            
            {this.acceptPaymentLink()}
            {this.acceptSwapLink()}
            
          </div>
          
          <div className="respond-buttons not-phone">
            <div className="offer-type">Decline Offer</div>
            {this.declineLink(true)}
            
          </div>

        </form>
      </div>
    )
  }
  
}
 