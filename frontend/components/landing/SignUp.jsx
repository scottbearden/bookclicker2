import React from "react";
import CreateUserForm from "../create_account/CreateUserForm";

export default class Auth extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <div className="create-user-page">
        <div className="create-user-form-container">
          <CreateUserForm />
        </div>
      </div>
    );
  }
}
