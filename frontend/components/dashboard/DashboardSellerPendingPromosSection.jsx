import React from "react";
import MessagerLink from "../../components/messages/MessagerLink";

export default class DashboardSellerPendingPromosSection extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    $(".seller-pending-promo-tooltip").tooltip({ position: top });
  }

  listsAndTheirPromos() {
    let lists = this.props.lists.filter(
      (list) => list.reservations_pending.length
    );
    if (!lists.length) {
      return (
        <div className="todays-promos-list">
          <div className="todays-promos-list-header">
            You have no pending reservations
          </div>
        </div>
      );
    }
    let result = [];
    lists.forEach((list, idx) => {
      result.push(
        <div key={idx} className="todays-promos-list">
          <div className="todays-promos-list-header">
            {list.adopted_pen_name || "Your list"} has the following booking
            requests pending:
          </div>

          <div className="todays-promos-list-promos">
            {this.expandPendingRequests(list)}
          </div>
        </div>
      );
    });
    return result;
  }

  actionTd(reservation) {
    let acceptLink = !reservation["payment_offer"] ? null : (
      <a
        href={"/reservations/" + reservation.id + "/accept"}
        target="_blank"
        className="bclick-button bclick-hollow-teal-button"
      >
        Accept
      </a>
    );

    let swapLink = !reservation["swap_offer"] ? null : (
      <a
        href={"/swap_calendar/" + reservation.id}
        target="_blank"
        className="bclick-button bclick-hollow-black-button"
      >
        See Swaps
      </a>
    );

    let declineLink = (
      <a
        href={"/reservations/" + reservation.id + "/decline"}
        target="_blank"
        className="bclick-button bclick-hollow-dark-red-button"
      >
        Decline
      </a>
    );

    return (
      <td className="pending-promo-link">
        {acceptLink}
        {swapLink}
        {declineLink}
      </td>
    );
  }

  expandPendingRequests(list) {
    // Variable to hold the last reservation date
    let lastDate = null;

    return list.reservations_pending.map((reservation, idx) => {
      // Check if the date has changed since the last reservation
      let hr = null;
      if (reservation.date_pretty !== lastDate && idx !== 0) {
        // If the date has changed, we'll insert a horizontal rule
        hr = <hr />;
      }
      lastDate = reservation.date_pretty;

      return (
        <div key={idx}>
          {hr}
          <table className="dashboard-activity-table space2">
            <tbody>
              <tr className="todays-promos-list-promo">
                <td className="no-text-shadow name-only">
                  {reservation.book.author} requesting a{" "}
                  <u>{reservation.inv_type}</u> on{" "}
                  <strong>{reservation.date_pretty}</strong> for{" "}
                  {reservation.recorded_list_name}.
                </td>

                <td className="no-text-shadow stat nudge-img-up">
                  {reservation.internal && list.pen_name ? (
                    <MessagerLink
                      to_obj={reservation.book}
                      tooltipTitle={
                        "Send message to " + reservation.book_author
                      }
                      myPenNames={[
                        {
                          id: list.pen_name_id,
                          author_name: list.pen_name.author_name,
                        },
                      ]}
                    />
                  ) : null}
                </td>

                <td className="no-text-shadow stat centerify">
                  <a
                    href={"/reservations/" + reservation.id + "/info"}
                    target="_blank"
                  >
                    <span
                      className="glyphicon glyphicon-info-sign seller-pending-promo-tooltip"
                      style={{ fontSize: "17px" }}
                      data-toggle="tooltip"
                      title="Click to see details page"
                    ></span>
                  </a>
                </td>

                <td className="no-text-shadow stat"></td>

                {this.actionTd(reservation)}
              </tr>
            </tbody>
          </table>
        </div>
      );
    });
  }

  render() {
    return (
      <div className="dashboard-activity-section extra-20">
        <div className="dashboard-activity-section-header">
          {"Pending Sales Activity"}
        </div>

        <div className="dashboard-activity-section-content">
          {this.listsAndTheirPromos()}
        </div>
      </div>
    );
  }
}
