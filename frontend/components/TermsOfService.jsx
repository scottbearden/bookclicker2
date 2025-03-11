import React from "react";
import { grabCsrfToken } from "../ext/functions";

export default class TermsOfService extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
    this.handleAccept = this.handleAccept.bind(this);
  }

  handleAccept() {
    let token = grabCsrfToken($);

    fetch("/terms_of_service/accept", {
      method: "POST",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": token,
        "Content-Type": "application/json",
      },
      credentials: "same-origin",
    })
      .then((response) => {
        if (!response.ok) {
          throw response;
        }
        window.location = "/";
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }

  render() {
    return (
      <div id="TermsOfService">
        <h1>Terms of Service</h1>
        <p>{this.props.terms}</p>
        <button onClick={this.handleAccept}>I Accept</button>
      </div>
    );
  }
}
