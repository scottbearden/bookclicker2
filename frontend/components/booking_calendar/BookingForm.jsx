import React from 'react';
import Slider, { Range } from 'rc-slider';
import { injectAuthenticityToken, pick } from '../../ext/functions';
import { iOS } from '../../ext/userAgent';
import Select from 'react-select';
import Toggle from 'react-toggle';
import MyListsApi from '../../api/MyListsApi';
import UsersApi from '../../api/UsersApi';
import AddNewBookForm from './AddNewBookForm';

export default class BookingForm extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      offerPayment: this.isSwapOnly() ? false : true,
      offerSwap: this.isSwapOnly() ? true : false,
      swap_offer_solo: false,
      swap_offer_feature: false,
      swap_offer_mention: false,
      formError: null,
      buyerLists: [],
      books: [],
      bookId: this.props.preselected_book ? this.props.preselected_book.id : null,
      penNames: [],
      showNewBookForm: false,
      premiumOffer: null,
      buyerSwapListId: null,
      auto_subscribe_on_booking: false };
  }

  autoSubscribeChange() {
    if (!this.state.auto_subscribe_on_booking) {
      this.setState({auto_subscribe_on_booking: 1}, this.saveAutoSubscribe.bind(this));
    } else {
      this.setState({auto_subscribe_on_booking: 0}, this.saveAutoSubscribe.bind(this));
    }
  }

  saveAutoSubscribe() {
    let data = pick(this.state, ['auto_subscribe_on_booking']);
    UsersApi.updateAutoSubscriptions(data).then(res => {
      this.setState({auto_subscribe_on_booking: !!res.auto_subscribe_on_booking})
    })
  }

  componentDidUpdate() {
    injectAuthenticityToken($, '.form-authenticity-token');
  }

  componentDidMount() {
    UsersApi.getCurrentUser().then(res => {
      this.setState({
        auto_subscribe_on_booking: !!res.user.auto_subscribe_on_booking,
        buyerLists: res.lists,
        books: res.books,
        penNames: res.pen_names
      })
    })
  }

  togglePaymentOffer(event) {
    if (this.state.offerPayment) {
      this.setState({offerPayment: false, premiumOffer: null});
    } else {
      this.setState({offerPayment: true, formError: null})
    }
  }

  toggleSwapOffer(event) {
    if (this.state.offerSwap) {
      this.setState({ offerSwap: false, buyerSwapListId: null }, () => {
        this.clearSwapOfferInvSelections();
      });
    } else {
      this.setState({offerSwap: true, formError: null})
    }
  }

  buyerSwapListOptions() {
    return this.state.buyerLists.map(list => {
      return { value: list.id, label: list.adopted_pen_name }
    })
  }

  bookOptions() {
    let bookOptions =  this.state.books.map(book => {
      return { value: book.id, label: book.title }
    })
    if (this.state.penNames.length) {
      bookOptions.push({ value: 'new', label: 'Add New' })
    }
    return bookOptions
  }

  buyerPremiumOptions() {
    let result = []
    for (let x = 1; x <= 200; x++) {
      result.push({label: ('$' + x.toString()), value: x})
    }
    return result;
  }

  buyerSwapSelectedList() {
    return this.state.buyerLists.find(list => {
      return list.id == this.state.buyerSwapListId;
    })
  }

  swapOfferInvTypes() {
    if (this.state.offerSwap) {
      if (!this.state.buyerSwapListId) {
        return (<div className="buyer-swap-list-message">You must select a list above</div>);
      } else {
        let invTypes = this.buyerSwapSelectedList().inv_types;
        if (!invTypes.length) {
          return (<div className="buyer-swap-list-message">You have no inventory for this list</div>)
        }
        let result = [];
        result.push(
          <div className="offer-in-exchange-message" key="swapForMessage">
            Swap for...
          </div>

        )
        invTypes.forEach(invType => {
          result.push(
            <div className="swap-offer-list-inv-type-1" key={invType} style={{width: (100.0/invTypes.length).toString() + '%'}}>
              <div className="buyer-swap-inv-type-label">{invType.capitalize()}</div>
              <input type="checkbox"
                 name={"reservation[swap_offer_" + invType}
                 value="1"
                 onChange={this.onSwapOfferInvChange.bind(this, invType)}
                 checked={this.state["swap_offer_" + invType]} />
            </div>
          )
        });
        return result;
      }
    } else {

    }
  }

  round5(x) {
    return Math.ceil(x/5)*5;
  }

  onBuyerSwapListSelection(event) {
    let buyerSwapListId = event ? event.value : null;
    this.setState({buyerSwapListId}, () => {
      this.clearSwapOfferInvSelections();
    })
  }

  onBookSelection(event) {
    let bookId = event ? event.value : null;
    let showNewBookForm = (bookId == 'new');
    this.setState({
      bookId, showNewBookForm
    })

  }

  onPremiumChange(value) {
    this.setState({premiumOffer: value - this.basePrice()})
  }

  onSwapOfferInvChange(invType) {
      switch(invType) {
      case 'solo':
        this.setState({swap_offer_solo: !this.state.swap_offer_solo})
        break;
      case 'feature':
        this.setState({swap_offer_feature: !this.state.swap_offer_feature})
        break;
      case 'mention':
        this.setState({swap_offer_mention: !this.state.swap_offer_mention})
        break;
      default:
        console.log('error')
    }
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
    return this.props.list[this.props.invType + "_price"] || 0;
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

  validateForm(event) {
    if (!this.state.offerPayment && !this.state.offerSwap) {
      event.preventDefault();
      this.setState({formError: 'You must offer either payment or swap'});
    } else if (this.state.offerSwap && !this.swapOfferSelectedInvTypes().length) {
      event.preventDefault();
      this.setState({formError: 'Swaps must offer a solo, feature, or mention to the seller'});
    } else if (!parseInt(this.state.bookId)) {
      event.preventDefault();
      this.setState({formError: 'You must select a book of yours to promote'})
    }
  }

  isSwapOnly() {
    return !!this.props.list[this.props.invType + "_is_swap_only"]
  }

  render() {
    return (
      <div className="booking-form">
        <div className="booking-form-title">
          Reserve {this.props.invType.capitalize()}
        </div>
        <form action='/reservations' method='POST' onSubmit={this.validateForm.bind(this)}>
          <input type="hidden" name="authenticity_token" className="form-authenticity-token" value=""/>
          <input type="hidden" name="inv_type" value={this.props.invType}/>
          <input type="hidden" name="date" value={this.props.date}/>
          <input type="hidden" name="list_id" value={this.props.list.id}/>

          <div className="book-select-container">
            <div className="book-select-header">
              Select Your Book
            </div>
            <Select
                  name="book_id"
                  clearable={false}
                  searchable={false}
                  autoBlur={true}
                  style={{cursor: 'pointer'}}
                  required
                  value={this.state.bookId || ''}
                  placeholder={"Select book"}
                  options={this.bookOptions()}
                  onChange={this.onBookSelection.bind(this)} />

          </div>

          <AddNewBookForm
           penNames={this.state.penNames}
           setBookingFormState={this.setState.bind(this)}
           showNewBookForm={this.state.showNewBookForm}
           bookId={this.state.bookId} />

          <div className={"payment-or-swap-container" + (this.isSwapOnly() ? " just-swap-open" : "")}>
            <div className={iOS() ? "ios offer-container" : "offer-container"} style={{display: this.isSwapOnly() ? "none" : "block"}}>
              <div className="payment-checkbox-container">
                <input type="checkbox"
                  name="reservation[payment_offer]"
                  value="1"
                  onChange={this.togglePaymentOffer.bind(this)}
                  checked={this.isSwapOnly() ? false : this.state.offerPayment} />
                <div>Offer Payment</div>
              </div>

              <div className={"payment-offer-content" + (this.state.offerPayment ? "" : " disabled")}>

                <span className={"payment-offer-slider-total"}>
                  ${this.basePricePlusPremium()}
                </span>

                <input
                  type="hidden"
                  value={this.state.premiumOffer || ''}
                  name="reservation[premium]"/>

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
                  disabled={!this.state.offerPayment}
                  onChange={this.onPremiumChange.bind(this)}
                  value={this.basePricePlusPremium()} />

                <a className='base-price' onClick={this.zeroPremiumPrice.bind(this)}><span>Original Price: ${this.basePrice()}</span></a>

              </div>
            </div>

            <div className={iOS() ? "ios offer-container" : "offer-container"}>
              <div className="swap-checkbox-container">
                <input type="checkbox"
                  name="reservation[swap_offer]"
                  value="1"
                  onChange={this.toggleSwapOffer.bind(this)}
                  checked={this.state.offerSwap} />
                <div>Offer Swap</div>
              </div>

              <div className="swap-offer-content">
                <div className="swap-offer-list-select">
                  <Select
                    name="reservation[swap_offer_list_id]"
                    clearable={false}
                    searchable={false}
                    autoBlur={true}
                    value={this.state.buyerSwapListId || ''}
                    disabled={!this.state.offerSwap}
                    placeholder={this.state.offerSwap ? "List to swap" : "---"}
                    options={this.buyerSwapListOptions()}
                    onChange={this.onBuyerSwapListSelection.bind(this)} />
                </div>

                <div className="swap-offer-list-inv-type">

                  {this.swapOfferInvTypes()}

                </div>
              </div>

            </div>

          </div>


          <div className="submit-container">
            <input
              type="submit"
              className="bclick-button bclick-solid-mailchimp-gray-button"
              value="Send Offer"/>

            <div className="submit-error">{this.state.formError}</div>
          </div>

          <div className="reservation-message-container">
            <textarea name="reservation[message]"
              placeholder="Include a note"
              className="form-control"/>

            <label className="auto-subscribe-toggle">
              <div className="space1-2 not-phone">Auto-Subscribe To List</div>
              <div className="space1-2 phone">Auto-Subscribe</div>
              <Toggle
                onChange={this.autoSubscribeChange.bind(this)}
                checked={!!this.state.auto_subscribe_on_booking}/>
            </label>

          </div>

        </form>
      </div>
    )
  }

}
