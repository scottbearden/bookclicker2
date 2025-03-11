import React from 'react';
import ReactDOM from 'react-dom';
import ReactDOMServer from 'react-dom/server';
import ReservationsApi from '../../api/ReservationsApi';
import BuyerConfirmationOptionsModal from './BuyerConfirmationOptionsModal';
import MessagerLink from '../../components/messages/MessagerLink';

export default class DashboardBuyerSentPromosSection extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      promos: this.props.acceptedPromos
    }
  }

  dismissPromo(promoId) {
    var that = this;
    ReservationsApi.dismiss(promoId, true).then(res => {
      $('#buyer-sent-promo-' + promoId).fadeOut(function() {
        let promos = that.state.promos.filter(promo => {
          return promo.id !== promoId;
        });
        that.setState({promos})
      })
    })
  }
  
  loadConfirmationOptionsModal(reservation) {
    let $modal = $('#reusableModal');
    let modalTitle = ReactDOMServer.renderToString(this.buyerSentPromoDescription(reservation, true))
    
    $modal.find('.modal-header').html(modalTitle)
    let $target = $modal.find('.modal-body').html('<div id="ConfirmationOptionsModal"></div>').find('#ConfirmationOptionsModal')[0]
    ReactDOM.render(
      <BuyerConfirmationOptionsModal
        updatePromo={this.updatePromo.bind(this)}
        reservation={reservation}/>, $target )
      
    $modal.modal({
      keyboard: true
    })
  }
  
  updatePromo(updatedPromo) {
    let promos = this.state.promos.map(promo => {
      return promo.id == updatedPromo.id  ? updatedPromo : promo
    })
    this.setState({promos})
  }
  
  acceptedPromos() {
    let promos = this.state.promos;
    if (!promos.length) {
      return (
        <tr className="no-text-shadow"><td className="no-books">You have no recent promos</td></tr>
      )
    }
    let result = [];
    promos.forEach((promo, idx) => {
      let statusLink = null;
      if (promo['refunded?']) {
        statusLink = (
          <button 
            onClick={this.loadConfirmationOptionsModal.bind(this, promo)} 
            className="bclick-button bclick-solid-youtube-red-button">
            <span>REFUNDED</span>
          </button>
        )
      } else if (promo["send_confirmed?"]) {
        statusLink = (
          <button 
            onClick={this.loadConfirmationOptionsModal.bind(this, promo)} 
            className="bclick-button bclick-solid-robin-egg-blue-button">
            <span>SENT</span>
          </button>
        )
      } else if (promo['refund_requested_at']) {
        statusLink = (
          <button 
            onClick={this.loadConfirmationOptionsModal.bind(this, promo)} 
            className="bclick-button bclick-hollow-youtube-red-button">
            <span>REFUND<br/>REQUESTED</span>
          </button>
        )
      } else if (promo['confirmation_requested_at']) {
        statusLink = (
          <button 
            onClick={this.loadConfirmationOptionsModal.bind(this, promo)} 
            className="bclick-button bclick-hollow-robin-egg-blue-button">
            <span>CONFIRM<br/>REQUESTED</span>
          </button>
        )
      } else {
        statusLink = (
          <button 
            onClick={this.loadConfirmationOptionsModal.bind(this, promo)} 
            className="bclick-button bclick-hollow-robin-egg-blue-button">
            <span>NOT SENT</span>
          </button>
        )
      }

      let allowDismiss = false;
      if (promo['refunded?'] || promo['send_confirmed?']) {
        allowDismiss = true;
      }
        
      result.push(
        <tr key={promo.id} className="dashboard-promo-feed-tr" id={"buyer-sent-promo-" + promo.id}>
          <td className="no-text-shadow name-only">{this.buyerSentPromoDescription(promo)}</td>
          <td className="no-text-shadow stat">
            { 
              promo.internal && promo.list.pen_name && promo.book.pen_name ? 
               <MessagerLink to_obj={promo.list} 
                             tooltipTitle={"Send message to " + promo.list.pen_name.author_name}
                             myPenNames={[{id: promo.book.pen_name.id, author_name: promo.book.pen_name.author_name}]} /> : null
            }
          </td>
          <td className="no-text-shadow stat"></td>
          <td className="no-text-shadow stat">
            <a
              onClick={this.dismissPromo.bind(this, promo.id)}
              style={{minWidth: '0px', display: allowDismiss ? "inline" : "none"}}
              className="bclick-button bclick-button bclick-solid-red-button">
              <span
                style={{color: 'darkred'}}
                className="glyphicon glyphicon-remove">
              </span>
            </a>
          </td>
          <td className="promo-sent-link fat">
            {statusLink}
          </td>
        </tr>

      )

      result.push(<tr key={idx.toString() + "-space"} className="space-tr"></tr> )
    })
    return result;
  }
  
  buyerSentPromoDescription(promo, big) {
    return (
      <div style={big ? {fontSize: '16px'} : {}}>
        {promo.recorded_list_name} sending {promo.book_title} on {promo.date_pretty}
      </div>
    )
  }


  render() {
    return (
      <div className="dashboard-activity-section extra-20">
        <div className="dashboard-activity-section-header">
          Promos Sent for You
        </div>
        <table className="dashboard-activity-table">
          <tbody>
            {this.acceptedPromos()}
          </tbody>
        </table>

      
      </div>
    )
  }
}
