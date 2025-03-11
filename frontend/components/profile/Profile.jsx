import React from 'react';
import { grabCsrfToken } from '../../ext/functions';
import { iOS } from '../../ext/userAgent';
import PageTitle from '../PageTitle';
import UsersApi from '../../api/UsersApi';
import UsersAssistantsApi from '../../api/UsersAssistantsApi';
import EmailVerifier from '../EmailVerifier';
import { pick } from '../../ext/functions';
import BuyerListSubscriptionsManager from './BuyerListSubscriptionsManager';
import VirtualAssistantsMangager from './VirtualAssistantsMangager';
import EmailNotificationsToggler from '../EmailNotificationsToggler';
import Select from 'react-select';
import SettleSellerPromosModal from '../shared/SettleSellerPromosModal';


export default class Profile extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      auto_subscribe_on_booking: props.user.auto_subscribe_on_booking,
      auto_subscribe_email: props.user.auto_subscribe_email || props.user.email,
      auto_subscribe_message: null,
      auto_subscribe_message_class: null,
      country: this.props.country,
      virtualAssistantInvitationEmail: this.props.user.last_assistant_invite ? this.props.user.last_assistant_invite.invitee_email : null,
      virtualAssistantInvitationPenName: this.props.user.last_assistant_invite ? this.props.user.last_assistant_invite.pen_name : null,
      virtualAssistantInvitationResponse: null
    };
  }
  
  autoSubscribeChange() {
    if (!this.state.auto_subscribe_on_booking) {
      this.setState({auto_subscribe_on_booking: 1}, this.saveAutoSubscribe.bind(this));
    } else {
      this.setState({auto_subscribe_on_booking: 0}, this.saveAutoSubscribe.bind(this));
    }
  }

  autoSubscribeEmailChange(event) {
    this.setState({auto_subscribe_email: event.target.value});
  }

  saveAutoSubscribe() {
    let data = pick(this.state, ['auto_subscribe_on_booking']);
    UsersApi.updateAutoSubscriptions(data).then(res => {
      //do nothing
    })
  }

  saveAutoSubscribeEmail(event) {
    event.preventDefault();
    let data = pick(this.state, ['auto_subscribe_email']);
    UsersApi.updateAutoSubscriptions(data).then(res => {
      this.setState({
        auto_subscribe_message: 'Saved',
        auto_subscribe_message_class: 'success'
      })
    }, (res) => {
      this.setState({
        auto_subscribe_message: res.responseJSON.message, 
        auto_subscribe_message_class: 'error'
      })
    })
  }
  
  countryOptions() {
    return BookclickerStaticData.stripeCountries
  }
  
  changeCountry(selection) {
    let country = selection ? selection.value : null
    this.setState({country}, function() {
      UsersApi.updateCountry(this.state.country)
    }) 
  }
  
  listSubscriptionsTool() {
    if (true) {
      return (
        <div className="profile-form-container">
          <div className="profile-form-header">
            Auto-subscribe To Lists
          </div>
          <form action="/users/auto_subscribe" method="POST" className="auto-subscribe-form">
            <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />

            <div className="auto-subscribe-input-container">
              <div className={"auto-subscribe-input"  + (iOS() ? " ios" : "")}>
                <input 
                  type="checkbox" 
                  name="user[auto_subscribe_on_booking]" 
                  value="1"
                  onChange={this.autoSubscribeChange.bind(this, 1)}
                  checked={this.state.auto_subscribe_on_booking == 1}/>
                <div className="auto-subscribe-input-label">Yes</div>
              </div>
            </div>

            <div className="auto-subscribe-input-container">
              <div className={"auto-subscribe-input"  + (iOS() ? " ios" : "")}>
                <input 
                  type="checkbox" 
                  name="user[auto_subscribe_on_booking]" 
                  value="0"
                  onChange={this.autoSubscribeChange.bind(this, 0)}
                  checked={this.state.auto_subscribe_on_booking == 0}/>
                <div className="auto-subscribe-input-label">No</div>
              </div>
            </div>

            <div className="profile-input" style={{height: 'auto'}}>
              <label className="centerlabel">Auto-subscribe Email</label>
              <input 
                type="email" 
                id="auto-subscribe-email"
                disabled={!this.state.auto_subscribe_on_booking}
                onChange={this.autoSubscribeEmailChange.bind(this)}
                name="user[auto_subscribe_email]" 
                value={this.state.auto_subscribe_on_booking ? (this.state.auto_subscribe_email || "") : ""}
                placeholder={this.state.auto_subscribe_on_booking ? "Email address" : "Disabled"} />

              <button 
                id="auto-subscribe-email-button"
                className="bclick-button bclick-solid-robin-egg-blue-button"
                onClick={this.saveAutoSubscribeEmail.bind(this)}>Update</button>

              <label className={"auto-subscribe-message " + (this.state.auto_subscribe_message_class || "")}>
                {this.state.auto_subscribe_message}
              </label>
            </div>

            <BuyerListSubscriptionsManager listSubscriptions={this.props.list_subscriptions}/>
                          
          </form>
        </div>
        
      )
    }
  }
  
  penNameOptions() {
    return this.props.pen_names.map(pen_name => {
      return { label: pen_name.author_name, value: pen_name.author_name }
    })
  }
  
  changeVirtualAssistantInvitationEmail(event) {
    this.setState({virtualAssistantInvitationEmail: event ? event.target.value : null})
  }
  
  changeVirtualAssistantInvitationPenName(selection) {
    this.setState({virtualAssistantInvitationPenName: selection ? selection.value : null})
  }
  
  sendVirtualAssistantInviteEmail() {
    if (!this.state.sendingVirtualAssistantInvite) {
      this.setState({sendingVirtualAssistantInvite: true}, function() {
        UsersAssistantsApi.invite(
          this.state.virtualAssistantInvitationEmail,
          this.state.virtualAssistantInvitationPenName).then(res => {
          this.setState({
            virtualAssistantInvitationResponse: <span style={{color: '#51C7B7'}}>Your invitation was sent</span>,
            sendingVirtualAssistantInvite: false
          })
        }, errRes => {
          let errMessage = (errRes && errRes.responseJSON.message) || "Something went wrong. Your invitation was not sent."
          this.setState({
            virtualAssistantInvitationResponse: <span style={{color: '#CD201F'}}>{errMessage}</span>,
            sendingVirtualAssistantInvite: false
          })
        })
      })
    }
  }
  
  virtualAssistantSelectTool() {
    
    let inviteFormDisabled = !!this.state.virtualAssistantUserId;
    
    let inviteForm = this.props.user['assistant?'] ? null : (
      <div style={{opacity: inviteFormDisabled ? '0.5' : '1.0'}}>
        <div className="profile-form-header">
          <div className="space1">Invite Virtual Assistant</div>    
          <div className="profile-form-subheader">
            Invite Your Virtual Assistant To Sign Up
          </div>
        </div>
        <div className="assistant-select">
          <label>To</label>
          <input 
            type="email"
            disabled={inviteFormDisabled}
            className="form-control"
            placeholder={this.state.virtualAssistantInvitationEmail ? "" : "Virtual Assistant Email"}
            onChange={this.changeVirtualAssistantInvitationEmail.bind(this)}
            value={this.state.virtualAssistantInvitationEmail || ''}/>
        </div>
        
        <div className="assistant-select">
          <label>From</label>
          <Select 
            type="text" 
            clearable={false}
            searchable={false}
            disabled={inviteFormDisabled}
            options={this.penNameOptions()}
            value={this.state.virtualAssistantInvitationPenName || ''}
            onChange={this.changeVirtualAssistantInvitationPenName.bind(this)}
            placeholder={this.state.virtualAssistantInvitationPenName ? "" : "Send Invite As"} />
        </div>
        
        <div className="assistant-select assistant-select-submit" style={{marginBottom: '5px'}}>
          <button
          disabled={inviteFormDisabled}
          className="bclick-button bclick-solid-mailchimp-gray-button va-invite-send"
            onClick={this.sendVirtualAssistantInviteEmail.bind(this)}>
            Send Invite
          </button>
        </div>
        <div className="assistant-select assistant-select-response">
          {this.state.virtualAssistantInvitationResponse}
        </div>
      </div>
    )
    
    if (!this.props.user['assistant?']) {
      return (
        <div className={"profile-form-container"}>
          <div className="profile-form-header">
            Manage Virtual Assistants
            <div className="profile-form-subheader">
              &nbsp;
            </div>
          </div>
          
          <VirtualAssistantsMangager 
            users_assistants={this.props.users_assistants} 
            all_assistants={this.props.all_assistants} />
          
          {inviteForm}
          
        </div>
      )
    }
  }
  
  confirmDeleteAssistantAccount(event) {
    event.preventDefault()
    if (confirm('Are you sure you wish to delete your account?')) {
      UsersApi.deleteAssistantAccount(this.props.user.id)
    }
  }
  
  deleteAssistantAccount() {
    if (this.props.user['assistant?']) {
      return (
        <div className={"profile-form-container"}>
          <div className="profile-form-header">
            Delete Account
            <div className="profile-form-subheader">
              Close account 
            </div>
          </div>
          
          <form onSubmit={this.confirmDeleteAssistantAccount.bind(this)}
            className="auto-subscribe-form">
            
            
            <div className="profile-submit">
              <input type="submit" value="Delete My Account" className="bclick-button bclick-solid-dark-red-button"/>
            </div>
            
          </form>
        
        </div>
      )
    }
  }
  
  submitRequestToDeleteFullMemberAccount() {
    if (confirm('Are you sure you want to close your account?')) {
      this.setState({deleteInProgress: true}, function() {
        UsersApi.deleteMemberAccount().then(res => {
          this.setState({deleteInProgress: false}, function() {
            if (res.affected_lists.length || res.affected_books.length) {
              SettleSellerPromosModal.showModal(res.affected_lists, res.affected_books, "account")
            } else {
              document.location = document.location;
            }
          })
        }, (resA, resB) => {
          this.setState({deleteInProgress: false}, function() {
            alert("Something went wrong");
          });
        })
      })
    }
  }
  
  deleteFullMemberAccount() {
    if (this.props.user['full_member?']) {
      return (
        <div className={"profile-form-container alone-center"}>
          <div className="profile-form-header">
            Close Account
          </div>
          
          <div className="profile-submit">
            <button 
               disabled={this.state.deleteInProgress}
               className="bclick-button bclick-solid-dark-red-button"
               onClick={this.submitRequestToDeleteFullMemberAccount.bind(this)}>
              Close My Account
            </button>
          </div>
        
        </div>
      )
    }
  }
  
  bookingNotificationsToggle() {
    return (
      <div className="profile-form-container thirds">
        <div className="profile-form-header">
          Booking Notifications
        </div>
        <form className="auto-subscribe-form">
          <div className="email-notifications-togglers">
            <EmailNotificationsToggler user={this.props.user} userField={"bookings_subscribed"} key={1}/>
          </div>
        </form>
      </div>
    )
  }
  
  confirmationNotificationsToggle() {
    return (
      <div className="profile-form-container thirds">
        <div className="profile-form-header">
          Send Confirmations
        </div>
        <form className="auto-subscribe-form">
          <div className="email-notifications-togglers">
            <EmailNotificationsToggler user={this.props.user} userField={"confirmations_subscribed"} key={2}/>
          </div>
        </form>
      </div>
    )
  }

  messagesNotificationsToggle() {
    return (
      <div className="profile-form-container thirds">
        <div className="profile-form-header">
          Message Notifications
        </div>
        <form className="auto-subscribe-form">
          <div className="email-notifications-togglers">
            <EmailNotificationsToggler user={this.props.user} userField={"messages_subscribed"} key={3}/>
          </div>
        </form>
      </div>
    )
  }
  
  updateInfoForm() {
    return (
      <div className="profile-form-container">
        <div className="profile-form-header">
          Update Info
        </div>
        <EmailVerifier user={this.props.user}/>
      </div>
    )
  }
  
  updatePasswordForm() {
    return (
      <div className="profile-form-container">
        <div className="profile-form-header">
          Change Password
        </div>
        <form action="/users/password" method="POST">
          <input type="hidden" name="_method" value="PUT"/>
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
          
          <div className="profile-input">
            <label>Password</label>
            <input 
              required
              type="password"
              minLength="8"  
              name="user[password]" 
              placeholder="New Password"/>
          </div>
          <div className="profile-input">
            <label>Confirm Password</label>
            <input 
              required
              type="password" 
              minLength="8" 
              name="user[password_confirmation]" 
              placeholder="Confirm New Password"/>
          </div>
          <div className="space1">&nbsp;</div><div className="space1">&nbsp;</div>
          <div className="profile-submit">
            <input type="submit" value="Save" className="bclick-button bclick-solid-robin-egg-blue-button"/>
          </div>
          
        </form>
      </div>
    )
  }
  
  render() {
    return (
      <div>
        <PageTitle title={'Edit Profile'} subtitles={[]} />
        
        <div className="profile-two-forms-container" style={{display: this.props.is_welcome ? 'none' : 'block'}}>
          {this.bookingNotificationsToggle()}
          {this.confirmationNotificationsToggle()}
          {this.messagesNotificationsToggle()}
        </div>   
        
        <div className="profile-two-forms-container">
          {this.updateInfoForm()}
          {this.updatePasswordForm()}
        </div>
        
        <div className="profile-two-forms-container">
          {this.listSubscriptionsTool()}
          {this.virtualAssistantSelectTool() || this.deleteAssistantAccount()}
        </div>
          
          
        <div className="profile-two-forms-container">
          {this.deleteFullMemberAccount()}
        </div>

      </div>
    )
  }
  
}
