import React from 'react';

export default class AssistantSignInLink extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {

    return (
      <div className="create-mailchimp-oauth">
        <div className="create-mailchimp-oauth-link-container">
          <a className="create-mailchimp-oauth-link bclick-button bclick-hollow-grey-button" 
            href={"/login"}>
            <div className="create-mailchimp-oauth-logo-container empty">
              <div className="create-mailchimp-oauth-logo">
              </div>
            </div>
            <span>Login With Email</span>
          </a>
        </div>
      </div>
    )

  }

}