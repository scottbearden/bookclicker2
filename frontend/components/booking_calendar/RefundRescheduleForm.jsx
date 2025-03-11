import React from "react";
import { hex, grabCsrfToken } from "../../ext/functions";
import { iOS } from "../../ext/userAgent";
import moment from "moment";
import OfferBookInfo from "./OfferBookInfo";

export default class RefundRescheduleForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      rescheduleDate: this.props.booking.date,
      rescheduleDateMoment: this.props.booking.date
        ? moment(this.props.booking.date)
        : null,
    };
  }

  componentDidMount() {
    $("#reusableModal .modal-footer").html("");
  }

  refundContainer() {
    if (this.canRefund()) {
      return (
        <div className={iOS() ? "ios offer-container" : "offer-container"}>
          <div className="swap-offer-content fixed-100">
            <label className="refund-amount">
              Refund ${this.props.booking.refundable_amount}
            </label>
            <div>Paid On {this.props.booking.paid_on}</div>
          </div>

          <div className={"respond-button"}>
            <a
              onClick={(e) => {
                if (!confirm("Are you sure you want to refund?"))
                  e.preventDefault();
              }}
              href={"/reservations/" + this.props.booking.id + "/refund"}
              className="bclick-button bclick-solid-mailchimp-gray-button respond-button-edit-button"
            >
              Refund
            </a>
          </div>
        </div>
      );
    }
  }

  cancelSwapContainer() {
    if (this.canCancelSwap()) {
      return (
        <div className={iOS() ? "ios offer-container" : "offer-container"}>
          <form
            action={"/reservations/" + this.props.booking.id + "/cancel_swap"}
            method="POST"
            onSubmit={(e) => {
              if (!confirm("Are you sure you want to cancel this swap?"))
                e.preventDefault();
            }}
          >
            <input
              type="hidden"
              name="authenticity_token"
              value={grabCsrfToken($)}
            />

            <div className="swap-offer-content fixed-100">
              <label className="refund-amount">Cancel Swap</label>
              <div className="swap-cancel-note"></div>
              <textarea
                name="seller_cancelled_reason"
                placeholder="Add a note to the other author to explain your reason for cancelling"
                className="form-control"
              ></textarea>
            </div>

            <div className={"respond-button"}>
              <input
                type="submit"
                value="Cancel Swap"
                className="bclick-button bclick-solid-mailchimp-gray-button respond-button-edit-button"
              ></input>
            </div>
          </form>
        </div>
      );
    }
  }

  datePicker() {
    return (
      <input
        type="date"
        className="form-control"
        value={this.state.rescheduleDate}
        required
        onChange={this.dateChangeHandlerWithoutMoment.bind(this)}
      />
    );
  }

  dateChangeHandlerWithMoment(rescheduleDateMoment) {
    let rescheduleDate = rescheduleDateMoment
      ? rescheduleDateMoment.format("YYYY-MM-DD")
      : null;
    this.setState({ rescheduleDateMoment, rescheduleDate, respondError: null });
  }

  dateChangeHandlerWithoutMoment(event) {
    let rescheduleDate = event.target ? event.target.value : null;
    let rescheduleDateMoment = rescheduleDate ? moment(rescheduleDate) : null;
    this.setState({ rescheduleDate, rescheduleDateMoment, respondError: null });
  }

  rescheduleContainer() {
    if (true) {
      return (
        <div
          className={
            (iOS() ? "ios offer-container" : "offer-container") +
            (!this.canRefund() && !this.canCancelSwap() ? " width-100" : "")
          }
        >
          <form
            action={"/reservations/" + this.props.booking.id + "/reschedule"}
            method="POST"
            onSubmit={this.validateRescheduleForm.bind(this)}
          >
            <input type="hidden" name="_method" value="PUT" />
            <input
              type="hidden"
              name="authenticity_token"
              value={grabCsrfToken($)}
            />
            <div className="swap-offer-content fixed-100">
              <div className="refund-amount">Reschedule To</div>
              <div className="swap-cancel-note"></div>
              {this.datePicker()}

              <div className="respond-error" style={{ color: "red" }}>
                {this.state.respondError}
              </div>

              <input
                type="hidden"
                name="reservation[date]"
                value={this.state.rescheduleDate}
              />
            </div>

            <div className={"respond-button"}>
              <input
                type="submit"
                value="Confirm Reschedule"
                className="bclick-button bclick-solid-mailchimp-gray-button respond-button-edit-button"
              ></input>
            </div>
          </form>
        </div>
      );
    }
  }

  canRefund() {
    return !!this.props.booking.refundable_amount;
  }

  canCancelSwap() {
    return this.props.booking["cancellable_swap?"];
  }

  validateRescheduleForm(event) {
    if (this.invalidRescheduleDate()) {
      event.preventDefault();
      this.setState({
        respondError: "You must select a date that hasn't passed",
      });
    } else {
      return null;
    }
  }

  invalidRescheduleDate() {
    if (!this.state.rescheduleDate) {
      return true;
    }
    var today = new Date();
    var yesterday = today.setDate(today.getDate() - 1);
    return Date.parse(this.state.rescheduleDate) <= yesterday;
  }

  render() {
    return (
      <div className="booking-form respond-booking-form">
        <div className="booking-form-title">
          {!this.canRefund() ? "Reschedule" : "Edit"}{" "}
          <a
            href={"/reservations/" + this.props.booking.id + "/info"}
            target="_blank"
          >
            {this.props.booking.inv_type.capitalize()} Offer
          </a>
          <div style={{ fontSize: "5px" }}>&nbsp;</div>
          <OfferBookInfo booking={this.props.booking} />
        </div>

        <div className={"payment-or-swap-container"}>
          {this.rescheduleContainer()}

          {this.refundContainer()}

          {this.cancelSwapContainer()}
        </div>
      </div>
    );
  }
}
