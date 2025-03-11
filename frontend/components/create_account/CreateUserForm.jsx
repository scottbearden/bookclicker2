import React from 'react';
import CreateUserBasicInputs from './CreateUserBasicInputs';
import { radioCheckBoxes } from '../../ext/functions';


export default class CreateUserForm extends React.Component {

  constructor(props) {
    super(props);
    this.state = {}
  }
    
  helpContent() {
    let linkSentence = null;
    if (this.props.provider == "convertkit") {
      linkSentence = (
        <span>
          Need help finding your api key? <a href="http://help.convertkit.com/article/74-convertkit-settings" target="_blank">Read here</a>
        </span>
      )
    } else if (this.props.provider == "mailerlite") {
      linkSentence = (
        <span>
          Need help finding your api key? <a href="https://kb.mailerlite.com/getting-started-with-mailerlite/#chapter11" target="_blank">Read here</a>
        </span>
      )
    }
    
    if (linkSentence) {
      return (
        <div className="create-user-input" style={{position: 'relative'}}>
            <div className="create-user-api-help">
              {linkSentence}
            </div>
        </div>
      )
    }
  }
  
  apiKeyInput() {
    if (!this.props.provider || this.props.provider == 'assistant') {
      return null;
    } else {
      return (
        <div className="create-user-input">
          <input type="hidden" name="api_key[platform]" value={this.props.provider}/>
          <input type="text" name="api_key[key]" placeholder={this.props.providerNice + " Api Key"} minLength="12" required/>
        </div>
      )
    }
  }
  
  render() {
    return (
      <form className="create-user-form" method="POST" action="/users">
        <input type="hidden" name="role" value={this.props.provider == 'assistant' ? 'assistant' : 'full_member'} />

        <CreateUserBasicInputs/>
      
        {this.helpContent()}
        {this.apiKeyInput()}
        
        <div className="create-user-submit-container">
          <div className="create-user-submit">
            <input 
              type="submit" value="Create Account" 
              className="bclick-button bclick-solid-robin-egg-blue-button bclick-no-text-transform-button" />
          </div>
        </div>

      </form>
    )
    
  }
  
}



