import React from 'react';
import ReactDOM from 'react-dom';
import ReservationsApi from '../../api/ReservationsApi';

export default class SettleSellerPromosModal extends React.Component {
    
  constructor(props) {
    super(props);
    this.state = {
      affectedLists: this.props.affectedLists,
      affectedBooks: this.props.affectedBooks,
      settledPromos: {}
    };
  }
  
  allSettled(promos) {
    let result = true;
    promos.forEach(promo => {
      if (!this.state.settledPromos[promo.id]) {
        result = false;
      }
    })
    return result;
  }
  
  render() {
    return (
      <div>
        {this.state.affectedLists.length ? <p className="promo-settle-section-note">We have successfully removed all affected lists from the marketplace so you will not receive new booking requests.  However, the following lists have bookings on their calendars.  You must resolve all these bookings in order to delete your{" " + this.props.entityBeingDeleted}.</p> : null}
        {this.state.affectedLists.length ? this.lists() : null}
        
        {this.state.affectedBooks.length ? <p className="promo-settle-section-note">The following books have bookings on their calendars.  You must resolve all these bookings in order to delete your{" " + this.props.entityBeingDeleted}.</p> : null}
        {this.state.affectedBooks.length ? this.books() : null}
      </div>
    )
  }
  
  lists() {
    
    // :last_minute_refundable?,
    // :cancellable_unpaid_promo?,
    // :last_minute_cancellable_swap?,
    // :swap_where_only_this_side_is_outstanding?,
    
    return this.state.affectedLists.map((list) => (
        <div key={list.id}>
          <h3 style={{textAlign: 'center'}}>
            <span>List: </span>{list.adopted_pen_name}
          </h3>
          {this.last_minute_refundable_promos(list.reservations_unconcluded, false)}
          {this.cancellable_unpaid_promos(list.reservations_unconcluded, false)}
          {this.last_minute_cancellable_swaps(list.reservations_unconcluded, false)}
          {this.swaps_where_only_this_side_is_outstanding(list.reservations_unconcluded, false)}
          <br/>
        </div>
      )
    )
  }
  
  
  books() {
    return this.state.affectedBooks.map((book) => (
        <div key={book.id}>
          <h3 style={{textAlign: 'center'}}>
            <span>Book: </span>{book.title}
          </h3>
          {this.last_minute_refundable_promos(book.reservations_unconcluded, true)}
          {this.cancellable_unpaid_promos(book.reservations_unconcluded, true)}
          {this.last_minute_cancellable_swaps(book.reservations_unconcluded, true)}
          {this.swaps_buyer_may_forfeit(book.reservations_unconcluded, true)}
          <br/>
        </div>
      )
    )
  }
  
  cancellable_unpaid_promos(_promos, isBuyer) {
    let promos = _promos.filter(promo => (promo["cancellable_unpaid_promo?"]));
    if (promos.length) {
      return (
        <div className="promo-settle-group" key="cancellable_unpaid_promos">
          <h5 className="promo-settle-header">Promos You May Cancel</h5>
          <button 
            disabled={this.allSettled(promos)}
            onClick={this.cancelAllSubmit.bind(this, promos)}
            className="promo-settle-all-btn btn btn-xs btn-warning">Cancel All</button>
            {this.promosDetails(promos, "cancel", isBuyer)}
        </div>
      )
    }
  }
  
  last_minute_cancellable_swaps(_promos, isBuyer) {
    let promos = _promos.filter(promo => (promo["last_minute_cancellable_swap?"]));
    if (promos.length) {
      return (
        <div className="promo-settle-group" key="last_minute_cancellable_swaps">
          <h5 className="promo-settle-header">Swaps You May Cancel</h5>
          <button 
            disabled={this.allSettled(promos)}
            onClick={this.cancelAllSubmit.bind(this, promos, isBuyer)}
            className="promo-settle-all-btn btn btn-xs btn-warning">Cancel All</button>
          {this.promosDetails(promos, "cancel", isBuyer)}
        </div>
      )
    }
  }
  
  swaps_where_only_this_side_is_outstanding(_promos, isBuyer) {
    let promos = _promos.filter(promo => (promo["swap_where_only_this_side_is_outstanding?"]));
    if (promos.length) {
      return (
        <div className="promo-settle-group" key="swaps_where_only_this_side_is_outstanding">
          <h5 className="promo-settle-header">Swaps You Must Confirm As Sent</h5>
          {this.promosDetails(promos, null, isBuyer)}
        </div>
      )
    }
  }
  
  swaps_buyer_may_forfeit(_promos, isBuyer) {
    let promos = _promos.filter(promo => (promo["swap_where_only_this_side_is_outstanding?"]));
    if (promos.length) {
      return (
        <div className="promo-settle-group" key="swaps_where_only_this_side_is_outstanding">
          <h5 className="promo-settle-header">Swaps You May Forfeit</h5>
          <button 
            disabled={this.allSettled(promos)}
            onClick={this.cancelAllSubmit.bind(this, promos, true)}
            className="promo-settle-all-btn btn btn-xs btn-warning">Forfeit All</button>
          {this.promosDetails(promos, "forfeit", true)}
        </div>
      )
    }
  }
  
  last_minute_refundable_promos(_promos, isBuyer) {
    let promos = _promos.filter(promo => (promo["last_minute_refundable?"]));
    if (promos.length) {
      return (
        <div className="promo-settle-group" key="last_minute_refundable_promos">
          <h5 className="promo-settle-header">Swaps You May Refund</h5>
          {this.promosDetails(promos, "refund", isBuyer)}
        </div>
      )
    }
  }
  
  promosDetails(promos, availableAction, isBuyer) {
    return promos.map(promo => {
      
      return (
        <ul key={promo.id}>
          <li key="type-date">
            <a href={"/reservations/" + promo.id + "/info"} target="_blank">
              <span>{promo.inv_type.capitalize()} on {promo.date_pretty}</span>
            </a>
          </li>
          <li key="title">{this.promosDetailsBookInfo(promo)}</li>
          {this.actionsLi(promo, availableAction, isBuyer)}
        </ul>
      )
    })
  }
  
  actionsLi(promo, availableAction, isBuyer) {
    
    if (promo["needs_confirm?"] || availableAction) {
      return (
        <li key="action">
          {availableAction ? this.actionButton(promo, availableAction, isBuyer) : null}
          {availableAction ? <span>&nbsp;&nbsp;</span> : null}
          {promo["needs_confirm?"] && !isBuyer ? this.confirmButton(promo) : null}
        </li>
      )
    }
  }
  
  promosDetailsBookInfo(promo) {
    if (promo.book_title && !promo.book_author) {
      return <span>{promo.book_title}</span>;
    } else if (promo.book_title && promo.book_author) {
      return <span>{promo.book_title} by {promo.book_author}</span>
    } else if (promo.book_author) {
      return <span>by {promo.book_author}</span>
    }
  }
  
  actionButton(promo, action, isBuyer) {
    let isSettled = this.state.settledPromos[promo.id];
    let buttonText = isSettled ? (action + "ed") : action;
    return (
      <button 
        disabled={isSettled}
        onClick={this.actionButtonAction.bind(this, promo, action, isBuyer)}
        className={"promo-settle-one-btn btn btn-xs " + (action == 'refund' ? 'btn-danger' : 'btn-warning') }>{buttonText.capitalize()}</button>
    )
  }
  
  confirmButton(promo) {
    let isSettled = this.state.settledPromos[promo.id];
    return (
      <a 
        disabled={isSettled}
        target="_blank"
        href={isSettled ? "" : ("/confirm_promos?resId=" + promo.id)}
        className={"promo-settle-one-btn btn btn-xs btn-info"}>Confirm</a>
    )
  }
  
  cancelAllSubmit(promos, isBuyer) {
    
    if (this.state.apiCallInProgress) {
      return null;
    }
    
    if (this.allSettled(promos)) {
      return null;
    }
    
    let reservationIds = promos.map(promo => (promo.id));
    
    let apiMethod = isBuyer ? ReservationsApi.buyerCancelAll : ReservationsApi.sellerCancelAll;
    apiMethod.call(ReservationsApi, reservationIds).then(res => {
      this.setState({apiCallInProgress: false}, function() {
        let { settledPromos } = this.state;
        res.reservation_ids && res.reservation_ids.forEach(resId => {
          settledPromos[resId] = true
        })
        this.setState({settledPromos})
      })
    }, resA => {
      this.setState({apiCallInProgress: false}, function() {
        alert('Something went wrong');
      })
      
    })
  }
  
  actionButtonAction(promo, action, isBuyer) {
    if (this.state.apiCallInProgress) {
      return null;
    }
    if (this.state.settledPromos[promo.id]) {
      return null;
    }
    
    let apiMethod = null;
    if (action == 'cancel' || action == 'forfeit') {
      apiMethod = isBuyer ? ReservationsApi.buyerCancel : ReservationsApi.sellerCancel
    } else if (action == 'refund') {
      apiMethod = isBuyer ? ReservationsApi.buyerRefund :  ReservationsApi.sellerRefund
    } else {
      return null;
    }
    
    this.setState({apiCallInProgress: true}, function() {
      apiMethod.call(ReservationsApi, promo.id).then(res => {
        let { settledPromos } = this.state;
        settledPromos[promo.id] = true;
        this.setState({settledPromos, apiCallInProgress: false});
      }, (resA, resB) => {
        this.setState({apiCallInProgress: false});
        let error = resA.responseJSON ? (resA.responseJSON.message || resA.responseJSON.error) : "Something went wrong";
        alert(error);
      })
    })
  }
  
  static showModal(affectedLists, affectedBooks, entityBeingDeleted) {
    let $modal = $('#reusableModal');
    let modalTitle = "<h4>Please Settle These Promos</h4>";

    $modal.find('.modal-header').html(modalTitle)
    let $target = $modal.find('.modal-body').html('<div id="SettleSellerPromosModal"></div>').find('#SettleSellerPromosModal')[0]
    ReactDOM.render(
      <SettleSellerPromosModal
      entityBeingDeleted={entityBeingDeleted}
        affectedBooks={affectedBooks}
        affectedLists={affectedLists} />, $target )
  
    $modal.modal({
      keyboard: true
    })
  }
  
}
