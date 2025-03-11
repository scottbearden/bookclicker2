import React from 'react';
import MailchimpOauthLink from '../MailchimpOauthLink';
import AweberOauthLink from '../AweberOauthLink';
import MailerLiteAuthLink from '../MailerLiteAuthLink';
import ConvertKitAuthLink from '../ConvertKitAuthLink';
import AssistantSignInLink from './AssistantSignInLink';
import { grabCsrfToken } from '../../ext/functions';

export default class SignInOptions extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  // render() {
 //    return (
 //      <div className="create-user-page">
 //        <div className="create-user-form-container">
 //          <MailchimpOauthLink role="sign_in" linkText="Sign In"/>
 //          <AweberOauthLink role="sign_in" linkText="Sign In"/>
 //          <MailerLiteAuthLink role="sign_in" linkText="Sign In"/>
 //          <ConvertKitAuthLink role="sign_in" linkText="Sign In"/>
 //          <AssistantSignInLink/>
 //
 //          <div className="sign-in-up-dont-already-text">
 //            Don’t have an account? <a href="/sign_up">Sign up for free</a>.
 //          </div>
 //
 //        </div>
 //      </div>
 //    )
 //  }
 
 
 render () {
   return (<div></div>)
 }
  
}  
  
        