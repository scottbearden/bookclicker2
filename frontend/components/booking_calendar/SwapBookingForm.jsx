import React from 'react';
import { injectAuthenticityToken, pick } from '../../ext/functions';
import { iOS } from '../../ext/userAgent';
import Select from 'react-select';
import Toggle from 'react-toggle';
import MyListsApi from '../../api/MyListsApi';
import MyBooksApi from '../../api/MyBooksApi';
import UsersApi from '../../api/UsersApi';
import OfferBookInfo from './OfferBookInfo';
import AddNewBookForm from './AddNewBookForm';

export default class SwapBookingForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      formError: null,
      bookId: null,
      showNewBookForm: false,
      books: [],
      bookId: null,
      penNames: [],
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
        books: res.books,
        penNames: res.pen_names
      })
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

  onBookSelection(event) {
    let bookId = event ? event.value : null;
    let showNewBookForm = (bookId == 'new');
    let newBookTitle = null;
    this.setState({
      bookId, showNewBookForm, newBookTitle
    })
  }
  
  validateForm(event) {
    if (!parseInt(this.state.bookId)) {
      event.preventDefault();
      this.setState({formError: 'You must select a book of yours to promote'})
    }
  }

  messageFromBuyer() {
    if (this.props.reservation.message) {
      return (
        <div>
        <br/><br/>
        <p>Message From Buyer: <i>{this.props.reservation.message}</i></p>
        </div>
      )
    }
  }
  
  render() {
    return (
      <div className="booking-form">
        <div className="booking-form-title swap">
          Swap For {this.props.invType.capitalize()} on {this.props.datePretty}
          <OfferBookInfo booking={this.props.reservation}/>
        </div>
        <form action={"/reservations/" + this.props.reservation.id + "/swap"} method='POST' onSubmit={this.validateForm.bind(this)}>
          <input type="hidden" name="authenticity_token" className="form-authenticity-token" value=""/>
          <input type="hidden" name="inv_type" value={this.props.invType}/>
          <input type="hidden" name="date" value={this.props.date}/>
          <input type="hidden" name="reservation[swap_offer]" value="1"/>
          <input type="hidden" name="list_id" value={this.props.list.id}/>

          <div className="book-select-container">
            <div className="book-select-header">
              Select Your Book
            </div>
            <Select
                  name="book_id"
                  clearable={false}
                  searchable={false}
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

          <div className={"payment-or-swap-container just-swap "}>
            <div className={iOS() ? "ios offer-container" : "offer-container"}>
              <span>You are about to exchange a {this.props.reservation.inv_type} promo with your list {this.props.reservation.list.adopted_pen_name} for this {this.props.invType} promo on {this.props.datePretty}.</span>
              {this.messageFromBuyer()}
            </div>
          </div>

          <div className="submit-container">
            <input 
              type="submit" 
              className="bclick-button bclick-solid-mailchimp-gray-button"
              value="Accept Swap"/>

            <div className="submit-error">{this.state.formError}</div>
          </div>

          <div className="reservation-message-container">
            <textarea name="reservation[message]" 
              placeholder="Include a reply message"
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
 