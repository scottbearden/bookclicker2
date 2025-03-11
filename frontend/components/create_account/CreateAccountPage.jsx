import React from 'react';
import PageTitle from '../PageTitle';
import CreateUserForm from '../create_account/CreateUserForm';

export default class CreateAccountPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  providerNice() {
    if (this.props.provider == 'mailerlite') {
      return 'MailerLite';
    } else if (this.props.provider == 'convertkit') {
      return 'ConvertKit';
    } else if (this.props.provider == 'mailchimp') {
      return 'MailChimp';
    } else if (this.props.provider == 'assistant') {
      return 'Virtual Assistant';
    }
  }
  
  logoSourceUrl() {
    if (this.props.provider == 'mailerlite') {
      return BookclickerStaticData.mailerliteLogoUrl;
    } else if (this.props.provider == 'convertkit') {
      return BookclickerStaticData.convertkitLogoUrl;
    } else if (this.props.provider == 'mailchimp') {
      return BookclickerStaticData.mailchimpLogoUrl;
    } else if (this.props.provider == 'assistant') {
      return null;
    }
  }
  
  preposition() {
    if (this.props.provider == 'assistant') {
      return "as a"
    } else {
      return "with"
    }
  }
  
  render() {
    let title = 'Bookclicker';
    let subtitles = [
      <span className='create-account-with' dangerouslySetInnerHTML={{__html: 'Sign Up ' + this.preposition() + ' <span style="color:black; font-weight: 600;">' + this.providerNice() + '</span>'}}/>
    ];
    
    if (this.logoSourceUrl()) {
      subtitles.push(<img src={this.logoSourceUrl()} className={'create-account-provider-logo'}/>)
    }
    
    return (
      
      <div className="create-user-page">
        {this.props.flashDiv}
        <PageTitle title={title} subtitles={subtitles}/>
        <div className="create-user-form-container">
          <CreateUserForm provider={this.props.provider} providerNice={this.providerNice()}/>
        </div>
      </div>
    )
  }
  
}