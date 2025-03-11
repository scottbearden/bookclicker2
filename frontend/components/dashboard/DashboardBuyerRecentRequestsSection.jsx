import React from 'react';
import ReservationsApi from '../../api/ReservationsApi';
import MessagerLink from '../../components/messages/MessagerLink';

export default class DashboardBuyerRecentRequestsSection extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      promos: this.props.requestedPromos
    }
  }

  dismissPromo(promoId) {
    var that = this;
    ReservationsApi.dismiss(promoId, false).then(res => {
      $('#recent-requests-feed-' + promoId).fadeOut(function() {
        let promos = that.state.promos.filter(promo => {
          return promo.id !== promoId;
        });
        that.setState({promos})
      })
    })
  }

  componentDidMount() {
    $('.buyer-recent-requests-tooltips').tooltip()
  }

  requestsFeed() {
    let promos = this.state.promos;

    if (!promos.length) {
      return (
        <tr className="no-text-shadow"><td className="no-books">Your buyer activity feed is empty</td></tr>
      )
    }
    let result = [];
    promos.forEach((promo, idx) => {

      let hrefPath = "/reservations/" + promo.id + "/info?jb=true";
      if (promo['awaiting_payment?']) {
        hrefPath = "/reservations/" + promo.id + "/pay";
      } else if (promo.status.match(/swapped/)) {
        hrefPath = "/reservations/" + promo.id + "/info"
      }

      let statusLabelClass = "";
      if (promo['awaiting_payment_and_seller_stripe_account_present?']) {
        statusLabelClass = "bclick-button bclick-solid-dark-green-button-button"
      } else if (promo.status.match(/accepted|paid|swapped/)) {
        statusLabelClass = "bclick-button bclick-hollow-teal-button"
      } else if (promo.status.match(/sent/)) {
        hrefPath = "/reservations/" + promo.id + "/info?jb=true"
        statusLabelClass = "bclick-button bclick-solid-robin-egg-blue-button"
      } else if (promo.status.match(/declined|cancelled|expired/)) {
        statusLabelClass = "bclick-button bclick-hollow-dark-red-button"
      } else if (promo.status.match(/pending/)) {
        statusLabelClass = "bclick-button bclick-hollow-robin-egg-blue-button"
      } else {
        statusLabelClass = "bclick-button bclick-hollow-black-button"
      }

      let tooltip = null;
      if (promo.status.match(/swapped/)) {
        tooltip = promo.swap_reservation.book_author + " took a " + promo.swap_reservation.inv_type + " on " + promo.swap_reservation.recorded_list_name + " on " + promo.swap_reservation.date_pretty + " in return"
      } else if (promo.status.match(/pending/)) {
        tooltip = "Request sent on " + promo.created_at_pretty
      } else if (promo.status.match(/cancelled/)) {
        tooltip = "Request cancelled because " + promo.cancelled_reason
      }

      let statusLink = (
        <a
          href={hrefPath}
          target="_blank"
          title={tooltip}
          className={statusLabelClass + " buyer-recent-requests-tooltips"}>
          <span>{promo['awaiting_payment_and_seller_stripe_account_present?'] ? 'pay now' : promo.status }</span>
        </a>
      )

      let penName = promo.recorded_list_name;
      result.push(
        <tr key={promo.id} id={"recent-requests-feed-" + promo.id} className="dashboard-promo-feed-tr">
          <td className="no-text-shadow name-only">Request{penName ? " to " + penName : "" } to send <i>{promo.book_title}</i> on {promo.date_pretty}</td>
          <td className="no-text-shadow stat">
            { 
              promo.internal && promo.list.pen_name && promo.book.pen_name ? 
               <MessagerLink to_obj={promo.list} 
                             tooltipTitle={"Send message to " + promo.list.pen_name.author_name}
                             myPenNames={[{id: promo.book.pen_name.id, author_name: promo.book.pen_name.author_name}]} /> : null
            }
          </td>
          <td className="no-text-shadow stat">
          </td>
          <td className="no-text-shadow stat promo-sent-link">
            <a
              onClick={this.dismissPromo.bind(this, promo.id)}
              style={{minWidth: '0px'}}
              className="bclick-button bclick-button bclick-solid-red-button">
              <span
                style={{color: 'darkred'}}
                className="glyphicon glyphicon-remove">
              </span>
            </a>
          </td>
          <td className="promo-sent-link">
            {statusLink}
          </td>
        </tr>

      )

      result.push(<tr key={idx.toString() + "-space"} className="space-tr"></tr> )
    })
    return result;
  }


  render() {
    return (
      <div className="dashboard-activity-section extra-20">
        <div className="dashboard-activity-section-header">
          Recent Requests
        </div>
        <table className="dashboard-activity-table">
          <tbody>
            {this.requestsFeed()}
          </tbody>
        </table>
      </div>
    )
  }
}
