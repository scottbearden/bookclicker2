import React from 'react';
import UsersApi from '../api/UsersApi';


export default class EmailVerifier extends React.Component {
	
  constructor(props) {
    super(props);
    this.state = { 
      email: this.props.user.email_unless_banned, 
      emailVerified: !!this.props.user.email_verified_at, 
      first_name: this.props.user.first_name,
      last_name: this.props.user.last_name,
      requesting: false, 
      lastSavedEmail: this.props.user.email_unless_banned}
    }

	updateEmail(event) {
		this.setState({email: event.target.value})
	}
  
  updateFirstName(event) {
    this.setState({first_name: event.target.value})
  }
  
  updateLastName(event) {
    this.setState({last_name: event.target.value})
  }
  
  saveIfEmailValid() {
    if (this.validEmail()) {
      UsersApi.updateBasicInfo({email: this.state.email}).then(res => {
        this.setState({email: res.email, lastSavedEmail: res.email, emailVerified: !!res.email_verified_at, error: null}, this.setSaveIndicator.bind(this, 'email', 800))
      }, errRes => {
        this.setState({error: (errRes.responseJSON && errRes.responseJSON.message) || 'This email could not be saved'})
      })
    } else {
      this.setState({error: 'Invalid email address'})
    }
  }
  
  saveFirstName() {
    
    UsersApi.updateBasicInfo({first_name: this.state.first_name}).then(res => {
      this.setSaveIndicator('first_name', 800)
    }, errRes => {
      if (errRes && errRes.responseJSON && errRes.responseJSON.message) {
        alert(errRes.responseJSON.message)
      }
    })
  }
  
  saveLastName() {
    UsersApi.updateBasicInfo({last_name: this.state.last_name}).then(res => {
      this.setSaveIndicator('last_name', 800)
    }, errRes => {
      if (errRes && errRes.responseJSON && errRes.responseJSON.message) {
        alert(errRes.responseJSON.message)
      }
    })
  }
  
  unsavedChanges() {
    return this.state.email !== this.state.lastSavedEmail;
  }

  showVerificationLinkWhen() {
    return !this.unsavedChanges() && this.validEmail() && !this.state.emailVerified
  }
  
  validEmail() {
    return this.state.email && this.state.email.match(/^[^@\s]+@([^@\s]+\.)+[^@\s]+$/);
  }

	linkText() {
		if (this.state.requesting) {
			return "Sending...";
		}
		if (this.state.requestSent) {
			return "Sent";
		}

		if (true) {
			return "Send Verification Email";
		}
	}

	verificationLinkDisabled() {
		return (this.state.requesting || this.unsavedChanges() || this.state.requestSent)
	}

	sendVerificationEmail() {
		if (this.verificationLinkDisabled()) {
			return null;
		}

		this.setState({requesting: true}, function() {
			UsersApi.sendVerificationEmail().then(res => {
        var that = this;
				this.setState({requesting: false, requestSent: true}, function() {
				  setTimeout(function() {
				    that.setState({requestSent: false})
				  }, 5000)
				})
		  }, (a,b) => {
		  	this.setState({requesting: false})
		  })
		})
	}
  
  emailVerifiedClass() {
    if (this.state.emailVerified) {
      if (!this.state.error) {
        return 'e-verified';
      }
    } else {
      return 'e-unverified'
    }
  }
  
  setSaveIndicator(saveIndicator, durationMs) {
    var that = this;
    this.setState({saveIndicator}, function() {
      setTimeout(function() {
        that.setState({saveIndicator: null})
      }, durationMs)
    })
  }

	render() {

		return (
      <form id="email-verifier-form">
        <div className="profile-input profile-input-auto-height">
          <label>Email</label>
          <label className="email-verified-error">
            {this.state.error}
          </label>
    			<div id="email-verifier-component">
    			  <input 
              className={(this.state.error ? 'email-verifier-error' : '') + ' ' + (this.state.saveIndicator == 'email' ? 'save-success' : '')}
              type="email" 
              required
              value={this.state.email || ''}
              onChange={this.updateEmail.bind(this)}
              onBlur={this.saveIfEmailValid.bind(this)}
              placeholder="Email"/>
            <div id="request-verification-email-link">
              &nbsp;&nbsp;
              <label className={this.emailVerifiedClass()}>
                [{this.state.emailVerified ? 'Verified' : 'Unverified'}]
              </label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <a 
    			      style={
                  {
                    cursor: this.verificationLinkDisabled() ? "default" : "pointer",
                    display: this.showVerificationLinkWhen() ? "inline" : "none"
                  }
                }
    	          onClick={this.sendVerificationEmail.bind(this)}
    	          disabled={this.verificationLinkDisabled()}>
    	          {this.linkText()}
    	        </a>
    			  </div>
    			</div>
        </div>
        <div className="profile-input">
          <label>First Name</label>
          <input 
            type="text" 
            className={(this.state.saveIndicator == 'first_name' ? 'save-success' : '')}
            value={this.state.first_name || ''}
            onChange={this.updateFirstName.bind(this)}
            onBlur={this.saveFirstName.bind(this)}
            placeholder="First Name"/>
        </div>
        <div className="profile-input">
          <label>Last Name</label>
          <input 
            type="text" 
            className={(this.state.saveIndicator == 'last_name' ? 'save-success' : '')}
            value={this.state.last_name || ''}
            onChange={this.updateLastName.bind(this)}
            onBlur={this.saveLastName.bind(this)}
            placeholder="Last Name"/>
        </div>
      </form>

		)
		
	}

}