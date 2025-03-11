import React from "react";
import PageTitle from "../PageTitle";
import CreateUserForm from "../create_account/CreateUserForm";

export default class CreateAccountPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    let title = "Bookclicker";
    let subtitle = (
      <span className="create-account-with">Sign Up for Bookclicker</span>
    );

    const urlParams = new URLSearchParams(window.location.search);
    const provider = urlParams.get("provider") || "full_member";

    return (
      <div className="create-user-page">
        {this.props.flashDiv}
        <PageTitle title={title} subtitles={[subtitle]} />
        <div className="create-user-form-container">
          <CreateUserForm provider={provider} />
        </div>
      </div>
    );
  }
}
