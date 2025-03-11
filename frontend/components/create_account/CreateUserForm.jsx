import React from "react";
import CreateUserBasicInputs from "./CreateUserBasicInputs";

export default class CreateUserForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    const isAssistant = this.props.provider === "assistant";

    return (
      <div>
        {isAssistant && (
          <div
            className="assistant-info-text"
            style={{
              textAlign: "center",
              marginBottom: "20px",
              fontStyle: "italic",
            }}
          >
            Virtual Assistant accounts must be linked to full member accounts to
            use Bookclicker features.
          </div>
        )}
        <form className="create-user-form" method="POST" action="/users">
          <input
            type="hidden"
            name="role"
            value={isAssistant ? "assistant" : "full_member"}
          />

          <CreateUserBasicInputs />

          <div className="create-user-submit-container">
            <div className="create-user-submit">
              <input
                type="submit"
                value="Create Account"
                className="bclick-button bclick-solid-robin-egg-blue-button bclick-no-text-transform-button"
              />
            </div>
          </div>
        </form>

        <div className="sign-in-up-dont-already-text">
          {isAssistant ? (
            <div>
              Full Member?{" "}
              <a href="/create_account?provider=full_member">Sign up here</a>.
            </div>
          ) : (
            <div>
              Virtual Assistant?{" "}
              <a href="/create_account?provider=assistant">Sign up here</a>.
            </div>
          )}
        </div>
      </div>
    );
  }
}
