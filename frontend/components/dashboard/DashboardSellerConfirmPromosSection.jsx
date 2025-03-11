import React from 'react';
import ReactDOM from 'react-dom';
import ReactDOMServer from 'react-dom/server';
import SellerConfirmationOptionsModal from './SellerConfirmationOptionsModal';

export default class DashboardSellerConfirmPromosSection extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {}
  }
  
  loadConfirmationOptionsModal(reservation) {
    let $modal = $('#reusableModal');
    let modalTitle = ReactDOMServer.renderToString(this.promoDescription(reservation, true))
    
    $modal.find('.modal-header').html(modalTitle)
    let $target = $modal.find('.modal-body').html('<div id="ConfirmationOptionsModal"></div>').find('#ConfirmationOptionsModal')[0]
    ReactDOM.render(
      <SellerConfirmationOptionsModal
        reservation={reservation}/>, $target )
      
    $modal.modal({
      keyboard: true
    })
  }
  
  promoDescription(promo, big) {
    return (
      <div style={big ? {fontSize: '16px'} : {}}>
        {promo.recorded_list_name} sending {this.sendingText(promo)}
      </div>
    )
  }
  
  sendingText(promo) {
    let text = "";
    
    if (promo.book_title) {
      text = promo.book_title
    } else if (promo.book_author) {
      text = " for " + promo.book_author
    } else {
      text = "untitled"
    }
    
    return text + ' on ' + promo.date_pretty;
  }
  
  linkText(promo) {
    if (promo.refund_requested_at) {
      return {
        html: <span>REFUND<br/>REQUESTED</span>,
        css: "bclick-button bclick-solid-youtube-red-button",
        url: "/reservations/" + promo.id + "/info?withRefundLink=true"
      }
    } else if (promo.confirmation_requested_at) {
      return {
        html: <span>CONFIRM<br/>REQUESTED</span>,
        css: "bclick-button bclick-solid-robin-egg-blue-button",
        url: "/confirm_promos?resId=" + promo.id
      }
    } else {
      return {
        html: <span>CONFIRM</span>,
        css: "bclick-button bclick-hollow-robin-egg-blue-button",
        url: "/confirm_promos?resId=" + promo.id
      }
    }
  }
  
  
  unconfirmedPromos() {
    let promos = this.props.promosForSendConfirmation;
    if (!promos.length) {
      return (
        <tr className="no-text-shadow"><td className="no-books">You have no promos to confirm</td></tr>
      )
    }
    let result = [];
    promos.forEach((promo, idx) => {
      
      let buttonOrLink = null;
      if (promo.refund_requested_at || promo['refundable?']) {
        buttonOrLink = (
          <button 
            id={"dashboard-seller-confirm-promo-button-" + promo.id}
            onClick={this.loadConfirmationOptionsModal.bind(this, promo)} 
            className={this.linkText(promo).css}>
            {this.linkText(promo).html}
          </button>
        )
      } else {
        buttonOrLink = (
          <a 
            href={this.linkText(promo).url}
            target="_blank" 
            className={this.linkText(promo).css}>
            {this.linkText(promo).html}
          </a>
        )
      }
        
      result.push(
        <tr key={idx} className="dashboard-promo-feed-tr">
          <td className="no-text-shadow name-only">{this.promoDescription(promo)}</td>
          <td className="no-text-shadow stat"></td>
          <td className="no-text-shadow stat"></td>
          <td className="no-text-shadow stat"></td>
          <td className="promo-sent-link fat">
            {buttonOrLink}
          </td>
        </tr>

      )

      result.push(<tr key={idx.toString() + "-space"} className="space-tr"></tr> )
    })
    return result;
  }
  
  componentDidMount() {
    if (this.props.prohibitiveRefundRequest) {
      let elemId = '#dashboard-seller-confirm-promo-button-' + this.props.prohibitiveRefundRequest.id;
      $(elemId).click()
    }
  }

  render() {
    return (
      <div className="dashboard-activity-section extra-20">
        <div className="dashboard-activity-section-header">
          Confirm Promos
        </div>
        <table className="dashboard-activity-table">
          <tbody>
            {this.unconfirmedPromos()}
          </tbody>
        </table>
      
      </div>
    )
  }
  
}
