import React from 'react';
import { grabCsrfToken } from '../../ext/functions';


export default class SignInForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  
  render() {
    return (
      <div className="create-user-page">
        <div className="space1">&nbsp;</div> 
        <div className="create-user-form-container">
          <form className="create-user-form" method="POST" action="/login">
      
            <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
      
            <div className="create-user-input create-user-email-input">
              <input 
                type="email" 
                name="email" 
                required
                placeholder="Email" />
            </div>

            <div className="create-user-input create-user-password-input">
              <input 
                type="password" 
                name="password" 
                minLength="6" 
                required
                placeholder="Password" />
            </div>
            <div className="request-reset-password-text">
              <span>Forgot your password?</span> <a href="/reset_password_request"><span>Reset your password</span></a>
            </div>
            

            <div className="create-user-submit-container">
              <div className="create-user-submit">
                <input 
                  type="submit" value="Sign In" 
                  className="bclick-button bclick-solid-robin-egg-blue-button bclick-no-text-transform-button" />
              </div>
            </div>

          </form>
          <div className="sign-in-up-dont-already-text">
            Don’t have an account? <a href="/sign_up">Sign up for free</a>.
          </div>
           
        </div>
      </div>
    )
  }
}
