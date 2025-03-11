import React from 'react';
import { grabCsrfToken } from '../../ext/functions';

export default class CreateUserBasicInputs extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    
    return (
      <div>
        <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
        
        <div className="create-user-input create-user-email-input">
          <input 
            type="text" 
            name="name" 
            required
            placeholder="Name" />
        </div>

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
            minLength="8" 
            required
            placeholder="Password" />
        </div>

        <div className="create-user-input">
          <input 
            type="password" 
            name="password_confirmation" 
            minLength="8" 
            required
            placeholder="Password Confirmation"/>
        </div>
      </div>
    )
  }
  
}