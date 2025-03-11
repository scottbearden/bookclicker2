import React from "react";
import { Link } from "react-router-dom";
import { grabCsrfToken } from "../../ext/functions";
import { iOS } from "../../ext/userAgent";
import PenNamesApi from "../../api/PenNamesApi";
import AmazonProductsApi from "../../api/AmazonProductsApi";
import MyBooksIndex from "../my_books/MyBooksIndex";

const PROMO_SERVICE_TYPES = ["unverified", "promo_service_only"];

export default class PenNameForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      validationError: null,
      penName: {
        id: this.props.penName ? this.props.penName.id : null,
        author_profile_url: this.props.penName
          ? this.props.penName.author_profile_url
          : null,
        author_name: this.props.penName ? this.props.penName.author_name : null,
        author_image: this.props.penName
          ? this.props.penName.author_image
          : null,
        verified: this.props.penName ? this.props.penName.verified : 0,
        promo_service_only: this.props.penName
          ? this.props.penName.promo_service_only
          : 0,
        pen_name_type: this.initialPenNameType(),
        group_status: this.props.penName
          ? this.props.penName.group_status
          : null,
      },
    };
  }

  wantsGroupAccess() {
    if (this.state.penName.promo_service_only) {
      return false;
    } else {
      return (
        this.state.penName.group_status == "open" ||
        this.state.penName.group_status == "closed"
      );
    }
  }

  initialPenNameType() {
    if (this.props.penName) {
      if (this.props.penName.promo_service_only) {
        return "promo_service_only";
        //} else if (this.props.penName.verified) {
        //  return "verified"
      } else {
        return "unverified";
      }
    } else {
      return "unverified";
    }
  }

  changePenNameType(event) {
    let type = event.target.value;
    let { penName } = this.state;
    penName.pen_name_type = type;
    penName.promo_service_only = type == "promo_service_only" ? 1 : 0;
    penName.author_profile_url = null;
    if (type == "verified") penName.author_name = null;

    this.setState({ penName }, function () {
      this.setPenNameVerified(0, undefined, null, null);
    });
  }

  changeGroupStatus(event) {
    let { penName } = this.state;
    penName.group_status = event.target.value;
    this.setState({ penName });
  }

  pillThirdSpace() {
    return (
      <div className="pen-name-pill-item blank-third">
        <div className="pen-name-pill-item-content">&nbsp;</div>
      </div>
    );
  }

  verifiedOrNotGlyphicon() {
    if (this.state.pingingAmazon) {
      return (
        <span
          className={
            "glyphicon glyphicon verified-or-not-glyphicon glyphicon-barcode"
          }
        ></span>
      );
    } else if (this.state.penName.verified) {
      return (
        <span
          className={"glyphicon  verified-or-not-glyphicon glyphicon-ok-circle"}
        ></span>
      );
    } else if (this.state.penName.author_profile_url) {
      return (
        <span
          className={
            "glyphicon  verified-or-not-glyphicon glyphicon-remove-circle"
          }
        ></span>
      );
    }
  }

  onChangeAuthorProfileUrl(event) {
    let { penName } = this.state;
    penName.author_profile_url = event ? event.target.value : null;
    var that = this;

    this.setState({ penName }, function () {
      if (this.state.pingingAmazon) {
        return null;
      }

      let url = this.state.penName.author_profile_url;
      //let match = url && url.toLowerCase().match(/(www\.amazon.+\/e\/b[a-z0-9]{9})/);

      //if (match) {
      that.setState({ pingingAmazon: true }, function () {
        AmazonProductsApi.getProfileAttrs(url).then(
          (res) => {
            that.setState({ pingingAmazon: false });
            if (res.valid) {
              that.setPenNameVerified(1, res.author_name, res.author_image);
            } else {
              that.setPenNameVerified(0, null, null);
            }
          },
          (errRes) => {
            that.setState({ pingingAmazon: false });
          }
        );
      });
      //} else {
      //  that.setPenNameVerified(0, null, null)
      //}
    });
  }

  onChangeAuthorName(event) {
    let { penName } = this.state;
    penName.author_name = event ? event.target.value : null;
    this.setState({ penName });
  }

  setPenNameVerified(verified, author_name, author_image, group_status) {
    let { penName } = this.state;
    if (verified !== undefined) penName.verified = verified;
    if (author_name !== undefined) penName.author_name = author_name;
    if (author_image !== undefined) penName.author_image = author_image;
    if (group_status !== undefined) penName.group_status = group_status;
    this.setState({ penName, validationError: null });
  }

  amazonUrlInputOrPenNameInput() {
    let placeholder = this.nameOrUrlPromptText().placeholder;

    if (this.wantsVerified()) {
      return (
        <div>
          <input
            type="text"
            className="form-control"
            required
            placeholder={placeholder}
            value={this.state.penName.author_profile_url || ""}
            onChange={this.onChangeAuthorProfileUrl.bind(this)}
          />

          {this.verifiedOrNotGlyphicon()}
        </div>
      );
    } else {
      return (
        <div>
          <input
            type="text"
            className="form-control"
            required
            placeholder={placeholder}
            value={this.state.penName.author_name || ""}
            onChange={this.onChangeAuthorName.bind(this)}
          />
        </div>
      );
    }
  }

  wantsVerified() {
    return this.state.penName.pen_name_type == "verified";
  }

  pillDeleteButton() {
    return (
      <div className="pen-name-pill-item blank-third">
        <div className="pen-name-pill-item-content">
          <button
            onClick={this.delete.bind(this)}
            disabled={this.state.deleting}
            className={
              "bclick-button " +
              (this.props.penName["can_delete?"]
                ? "bclick-solid-light-red-button"
                : "bclick-solid-light-grey-button")
            }
            value={this.state.deleting ? "Deleting..." : "Delete"}
          >
            Delete
          </button>
        </div>
      </div>
    );
  }

  delete(event) {
    if (!confirm("Are you certain you want to delete this pen name?")) {
      return;
    }
    event.preventDefault();
    if (this.state.deleting) return;
    PenNamesApi.delete(this.state.penName.id).then(
      (res) => {
        this.setState({ deleting: false });
        document.location = "/pen_names";
      },
      (errRes) => {
        let message =
          errRes && errRes.responseJSON
            ? errRes.responseJSON.message
            : "Could not delete pen name";
        this.props.setFlash(message, "danger");
        this.setState({ deleting: false });
      }
    );
  }

  save(event) {
    event.preventDefault();
    if (this.state.saving) return;

    if (this.wantsVerified() && this.state.pingingAmazon) {
      this.setState({
        validationError: "We are still validating your amazon profile url",
      });
      return null;
    } else if (this.wantsVerified() && !this.state.penName.verified) {
      this.setState({
        validationError: "Please enter a verifiable amazon profile url",
      });
      return null;
    }

    let apiCall;
    if (this.state.penName.id) {
      apiCall = PenNamesApi.update.bind(
        PenNamesApi,
        this.state.penName.id,
        this.state.penName
      );
    } else {
      apiCall = PenNamesApi.create.bind(PenNamesApi, this.state.penName);
    }

    //, accepted, unauthorized, created
    this.setState({ saving: true, validationError: null }, function () {
      apiCall().then(
        (res) => {
          let message = "Pen Name was saved successfully";
          if (res.message) {
            message = res.message;
          } else if (this.state.penName.promo_service_only) {
            message = "Promo Service was saved successfully";
          }

          this.setState({ saving: false }, function () {
            this.props.setFlash(message, "success");
            this.props.reloadPenNames();
            this.props.closeNewPenNameForm();
          });
        },
        (errRes) => {
          let message =
            errRes && errRes.responseJSON
              ? errRes.responseJSON.message
              : "Pen Name failed to save";
          if (errRes.status == 400 || errRes.status >= 500) {
            this.setState({ saving: false, validationError: message });
          } else {
            this.props.setFlash(message, "default");
            this.setState({ saving: false, validationError: message });
          }
        }
      );
    });
  }

  groupPenNameSelect() {
    if (this.state.penName.promo_service_only) return null;
    return (
      <div className="clearfix">
        <div className="enter-amazon-profile-text">Group Pen Name</div>

        {this.pillThirdSpace()}
        <div className="pen-name-pill-item center-input">
          <div
            className={
              "pen-name-pill-item-content has-checkbox" + (iOS() ? " ios" : "")
            }
          >
            <input
              type="checkbox"
              checked={this.wantsGroupAccess()}
              onChange={this.toggleGroupAccess.bind(this)}
            />
          </div>
        </div>
        {this.pillThirdSpace()}
      </div>
    );
  }

  groupAccessSelect() {
    if (this.state.penName.promo_service_only || !this.wantsGroupAccess())
      return null;
    return (
      <div className="clearfix">
        <div className="enter-amazon-profile-text">Group Access</div>
        {this.pillThirdSpace()}
        <div className="pen-name-pill-item center-input">
          <div className="pen-name-pill-item-content">
            <select
              className="form-control"
              value={this.state.penName.group_status || ""}
              onChange={this.changeGroupStatus.bind(this)}
            >
              <option value="open">Open</option>
              <option value="closed">Closed</option>
            </select>
          </div>
        </div>
        {this.pillThirdSpace()}
      </div>
    );
  }

  toggleGroupAccess(event) {
    const { penName } = this.state;
    penName.group_status = event.target.checked ? "open" : null;
    this.setState({ penName });
  }

  nameOrUrlPromptText() {
    if (this.wantsVerified()) {
      return {
        header: "Amazon Profile Url",
        placeholder: "www.amazon.com/William-Shakespeare/e/B000APWKO4",
      };
    } else if (this.state.penName.promo_service_only) {
      return { header: "Promo Name", placeholder: "My Promo Service" };
    } else {
      return { header: "Author Name", placeholder: "My Pen Name" };
    }
  }

  render() {
    return (
      <div className="pen-name-pill-content">
        <div className="enter-amazon-profile-text">Type Of Service</div>
        {this.pillThirdSpace()}
        <div className="pen-name-pill-item center-input">
          <div className="pen-name-pill-item-content">
            <select
              className="form-control"
              value={this.state.penName.pen_name_type}
              onChange={this.changePenNameType.bind(this)}
            >
              <option value="unverified">Pen Name</option>
              <option value="promo_service_only">Promo Service</option>
            </select>
          </div>
        </div>
        {this.pillThirdSpace()}

        <div className="space1">&nbsp;</div>

        <div className="enter-amazon-profile-text">
          {this.nameOrUrlPromptText().header}
        </div>
        {this.pillThirdSpace()}
        <div className="pen-name-pill-item center-input">
          <div className="pen-name-pill-item-content">
            {this.amazonUrlInputOrPenNameInput()}
          </div>
        </div>
        {this.pillThirdSpace()}

        <div className="space1">&nbsp;</div>

        {this.groupPenNameSelect()}
        {this.groupAccessSelect()}

        <div className="space1">&nbsp;</div>

        {this.props.penName && this.props.penName.id
          ? this.pillDeleteButton()
          : this.pillThirdSpace()}
        <div className="pen-name-pill-item center-input">
          <div className="pen-name-pill-item-content">
            <input
              type="submit"
              onClick={this.save.bind(this)}
              disabled={this.state.saving}
              className="bclick-button bclick-solid-mailchimp-gray-button"
              value={this.state.saving ? "Saving..." : "Save"}
            />
          </div>
        </div>
        {this.pillThirdSpace()}

        <div
          className="new-pen-name-validation-error"
          dangerouslySetInnerHTML={{
            __html: this.state.validationError || " ",
          }}
        ></div>

        <div className="space1">&nbsp;</div>
      </div>
    );
  }
}
