import React from 'react';

export default class MailerLiteAuthLink extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  sendTo() {
    return "/create_account?provider=mailerlite";
  }

  render() {
    
    return (
      <div className="create-mailchimp-oauth">
        <div className="create-mailchimp-oauth-link-container">
          <a className="create-mailchimp-oauth-link bclick-button bclick-hollow-grey-button" 
            href={this.sendTo()}>
            <div className="create-mailchimp-oauth-logo-container">
              <div className="create-mailchimp-oauth-logo">
                <img src={BookclickerStaticData.mailerliteLogoUrl}/>
              </div>
            </div>
            <span>{this.props.linkText} <span className="hide-mobile">With MailerLite</span></span>
          </a>
        </div>
      </div>
    )

  }

}