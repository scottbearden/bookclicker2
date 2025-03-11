import React from 'react';
import withIntegrator from './withIntegrator';
import MailchimpOauthLink from '../MailchimpOauthLink';
import AweberOauthLink from '../AweberOauthLink';

class OAuthIntegrator extends React.Component {
  
  integrationLink() {

    if (this.props.api_key.platform == 'mailchimp') {
      return <MailchimpOauthLink linkText={'Integrate'} role={'integrate'}/>
    } else if (this.props.api_key.platform == 'aweber') {
      return <AweberOauthLink linkText={'Integrate'} role={'integrate'}/>
    } else {
      return null;
    }
    
  }
  
  render() {
    return (
      <div>
      
        {this.props.deleteButton()}
    
        {this.integrationLink()}
    
        <span className="integration-error">{this.props.errorMessage || ' '}</span>
      
      </div>
    )
  }
  
}

const OAuthIntegratorWithIntegrator = withIntegrator(OAuthIntegrator);
export default OAuthIntegratorWithIntegrator;
  
  