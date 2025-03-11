import React from 'react';

export default class MailchimpOauthLink extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {

    return (
      <div className={"create-mailchimp-oauth"}>
        <div className="create-mailchimp-oauth-link-container">
          <a className="create-mailchimp-oauth-link bclick-button bclick-hollow-grey-button" 
            href={"/mailchimp/auth?role=" + this.props.role}>
            <div className="create-mailchimp-oauth-logo-container">
              <div className="create-mailchimp-oauth-logo">
                <img src={BookclickerStaticData.mailchimpLogoUrl}/>
              </div>
            </div>
            <span>{this.props.linkText} <span className="hide-mobile">With MailChimp</span></span>
          </a>
        </div>
      </div>
    )

  }

}