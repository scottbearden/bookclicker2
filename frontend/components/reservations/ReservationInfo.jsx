import React from "react";
import { addCommasToNum, decimalToPercent } from "../../ext/functions";

export default class ReservationInfo extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  swappingWithSelf() {
    return (
      this.props.reservation &&
      this.props.swap_reservation &&
      this.props.reservation.im_sending_this &&
      this.props.swap_reservation.im_sending_this
    );
  }

  collectDataForReservation(
    results,
    reservation,
    book,
    list,
    confirmed_campaign
  ) {
    if (
      !this.props.limitedInfo &&
      (reservation["accepted?"] || reservation["cancelled?"])
    ) {
      if (this.swappingWithSelf()) {
        //in case someone is testing by swapping with themself
        results.push([
          <h4 style={{ textAlign: "center" }}>I Have Swapped With Myself</h4>,
          null,
          "wide",
        ]);
      } else if (reservation.im_sending_this) {
        results.push([
          <h4 style={{ textAlign: "center" }}>
            {reservation["send_confirmed?"]
              ? "I Have Sent This Promo"
              : "I Am Sending This Promo"}
          </h4>,
          null,
          "wide",
        ]);
      } else {
        results.push([
          <h4 style={{ textAlign: "center" }}>
            {reservation["send_confirmed?"]
              ? "This Promo Was Sent For Me"
              : "This Promo Is Being Sent For Me"}
          </h4>,
          null,
          "wide",
        ]);
      }
    }

    results.push(["Date", reservation.date_pretty]);
    results.push(["Type of Booking", reservation.inv_type]);

    if (reservation["price_in_play?"]) {
      results.push(["Price", "$" + reservation.payment_offer_total]);
    }

    if (reservation["swap_in_play?"]) {
      let swapText = reservation["swap_offer_accepted?"]
        ? "Accepted"
        : "Offered - " + reservation.swap_offer_inv_types.join(" or ");
      results.push(["Swap", swapText]);
    }

    if (confirmed_campaign) {
      results.push(["", <div style={{ backgroundColor: "grey" }} />, true]);

      if (confirmed_campaign.preview_url) {
        results.push([
          "Email Preview",
          <a href={confirmed_campaign.preview_url} target="_blank">
            preview
          </a>,
        ]);
      }

      if (confirmed_campaign.emails_sent) {
        results.push([
          "Email Recipients",
          addCommasToNum(confirmed_campaign.emails_sent),
        ]);
      }

      if (confirmed_campaign.open_rate > 0.1) {
        results.push([
          "Email Open Rate",
          decimalToPercent(confirmed_campaign.open_rate),
        ]);
      }

      if (confirmed_campaign.click_rate > 0.1) {
        results.push([
          "Email Click Rate",
          decimalToPercent(confirmed_campaign.click_rate),
        ]);
      }
    }

    results.push(["", <div style={{ backgroundColor: "grey" }} />, true]);

    if (book && book.author) {
      results.push(["Buyer's Name", book.author]);
    }

    if (book && book.title) {
      results.push(["Book Title", book.title]);
    }

    if (book && book.amazon_link_url) {
      results.push([
        "Amazon Link",
        <a target="_blank" href={book.amazon_link_url}>
          Amazon Link
        </a>,
      ]);
    }

    if (book && book.google_play_link_url) {
      results.push([
        "Google Link",
        <a target="_blank" href={book.google_play_link_url}>
          Google Link
        </a>,
      ]);
    }

    if (book && book.itunes_link_url) {
      results.push([
        "Itunes Link",
        <a target="_blank" href={book.itunes_link_url}>
          Itunes Link
        </a>,
      ]);
    }

    if (book && book.other_link_urls) {
      book.other_link_urls.forEach((otherLinkUrl) => {
        results.push([
          "Other Link",
          <a target="_blank" href={otherLinkUrl}>
            Other Link
          </a>,
        ]);
      });
    }

    results.push(["", <div style={{ backgroundColor: "grey" }} />, true]);

    if (reservation.recorded_list_name) {
      results.push(["List Name", reservation.recorded_list_name]);
    }
    if (list && list.active_member_count_delimited) {
      results.push(["List Size", list.active_member_count_delimited]);
    }

    if (list && list.Platform) {
      results.push(["List Provider", list.Platform]);
    }

    if (list && list.open_rate_percent && !this.props.limitedInfo) {
      results.push(["Open Rate", list.open_rate_percent]);
    }

    if (list && list.click_rate_percent && !this.props.limitedInfo) {
      results.push(["Click Rate", list.click_rate_percent]);
    }

    return results;
  }

  infoTrs() {
    let trsData = [];

    this.collectDataForReservation(
      trsData,
      this.props.reservation,
      this.props.book,
      this.props.list,
      this.props.confirmed_campaign
    );

    if (
      !this.props.limitedInfo &&
      !this.props.just_buyer_side &&
      this.props.swap_reservation
    ) {
      this.collectDataForReservation(
        trsData,
        this.props.swap_reservation,
        this.props.swap_book,
        this.props.swap_list
      );
    }

    let trs = [];

    trsData.forEach((trData, idx) => {
      trs.push(
        <tr key={idx} className={trData[2] ? "divider" : ""}>
          <td colSpan={trData[2] == "wide" ? 2 : 1}>{trData[0]}</td>

          {trData[1] ? <td>{trData[1]}</td> : null}
        </tr>
      );
    });
    return trs;
  }

  render() {
    return (
      <div className="reservation-info-container">
        <div
          className={
            this.props.reservation["accepted?"]
              ? "reservation-info accepted"
              : "reservation-info"
          }
        >
          <table
            className={this.props.limitedInfo ? "table table-striped" : "table"}
          >
            <thead
              style={{
                display: this.props.limitedInfo ? "none" : "table-header-group",
              }}
            >
              <tr
                className={
                  "reservation-info-header" +
                  " " +
                  this.props.reservation.status
                }
              >
                <td colSpan="100%">
                  {this.props.limitedInfo
                    ? ""
                    : this.props.reservation.status_plus.toUpperCase()}
                </td>
              </tr>
            </thead>

            <tbody>{this.infoTrs()}</tbody>
          </table>
        </div>
      </div>
    );
  }
}
