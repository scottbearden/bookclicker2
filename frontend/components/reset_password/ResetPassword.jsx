import React from 'react';
import PageTitle from '../PageTitle';
import { grabCsrfToken } from '../../ext/functions';

import { BrowserRouter, Match, Route, Link } from 'react-router-dom';

export default class ResetPassword extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    return (
      <div id="reset-password-page">
        <PageTitle title={'Reset Password'} subtitles={[]}  />
        
        <div className="create-user-page">
          <div className="space1">&nbsp;</div> 
          <div className="create-user-form-container">
            
            
            <form className="create-user-form" method="POST" action="/reset_password">
    
              <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
              <input type='hidden' name='token' value={this.props.token} />
              
              <label className="create-user-reset-password-label">New Password</label>

              <div className="create-user-input reset-password-input">
                
                <input 
                  type="password" 
                  name="password" 
                  minLength="8" 
                  required
                  placeholder="New Password" />
              </div>
            
              <label className="create-user-reset-password-label">Confirm New Password</label>
              
              <div className="create-user-input reset-password-input">
                
                <input 
                  type="password" 
                  name="password_confirmation" 
                  minLength="8" 
                  required
                  placeholder="Password Confirmation" />
              </div>

              <div className="create-user-submit-container">
                <div className="create-user-submit">
                  <input 
                    type="submit" value="Save New Password" 
                    className="bclick-button bclick-solid-robin-egg-blue-button bclick-no-text-transform-button" />
                </div>
              </div>

            </form>
          
          </div>
        </div>
        
      </div>
    )
  }
  
}
