import React from 'react';
import MailchimpOauthLink from '../MailchimpOauthLink';
import AweberOauthLink from '../AweberOauthLink';
import MailerLiteAuthLink from '../MailerLiteAuthLink';
import ConvertKitAuthLink from '../ConvertKitAuthLink';

export default class Auth extends React.Component {

  constructor(props) {
    super(props);
    this.state = {}
  }
  
  render() {
    return (
      <div className="create-user-page">
      
        <div className="create-user-form-container">
        
          <div className="sign-in-up-dont-already-text no-margin-top">
            Already a member? <a href="/login">Sign in here</a>.
          </div>
        
          <MailchimpOauthLink role="full_member" linkText="Sign Up"/>
          <AweberOauthLink role="full_member" linkText="Sign Up"/>
          <MailerLiteAuthLink linkText="Sign Up"/>
          <ConvertKitAuthLink linkText="Sign Up"/>
          
          <div className="sign-in-up-dont-already-text">
            Virtual Assistant? <a href="/create_account?provider=assistant">Sign up here</a>.
          </div>
          
        </div>
      </div>
    )
  }
}