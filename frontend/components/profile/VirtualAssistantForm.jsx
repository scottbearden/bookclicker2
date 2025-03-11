import React from 'react';
import UsersAssistantsApi from '../../api/UsersAssistantsApi';
import Select from 'react-select';

export default class VirtualAssistantForm extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      assistantId: this.props.assistantId,
      response: null,
      paymentRequest: this.props.paymentRequest || {}
    }
  }
  
  assistantOptions() {
    return this.props.all_assistants.map((assistant, idx) => {
      return { label: assistant.full_name_or_email, value: assistant.id }
    })
  }
  
  changeAssistant(selection) {
    let assistantIdWas = this.state.assistantId
    let assistantId = selection ? selection.value : null;
    var that = this;
    
    this.setState({assistantId, saving: true}, function() {
      this.apiMethod(assistantId).call().then(res => {
        this.setState({
          response: (<span style={{color: '#51C7B7'}}>{res.message}</span>)
        }, function() {
          setTimeout(function() {
            that.setState({saving: false}, function() {
              if (res.users_assistants) {
                that.props.rerenderVirtualAssistantManager(res.users_assistants)
              }
            })
          }, 800)
        })
      }, errRes => {
        this.setState({
          saving: false, 
          assistantId: assistantIdWas,
          response: (<span style={{color: '#CD201F'}}>{errRes.responseJSON ? errRes.responseJSON.message : 'Data did not save'}</span>)
        })
      })
    })
  }
  
  apiMethod(newAssistantId) {
    if (this.props.joinId) {
      if (newAssistantId) {
        return UsersAssistantsApi.update.bind(UsersAssistantsApi, this.props.joinId, newAssistantId)
      } else {
        return UsersAssistantsApi.destroy.bind(UsersAssistantsApi, this.props.joinId)
      }
    } else if (newAssistantId) {
      return UsersAssistantsApi.create.bind(UsersAssistantsApi, newAssistantId)
    } else {
      return function() {
        return new Promise(function(resolve, reject) {
          resolve({message: null});
        })
      }
    }
  }
  
  activeStatus() {
    return this.state.paymentRequest.last_known_subscription_status
  }
  
  activeLabel() {
    if (this.activeStatus()) {
      return (
        <label>Stripe status: {this.activeStatus().capitalize()}</label>
      )
    }
  }
  
  activeInputText() {
    if (this.activeStatus() == "past_due" || this.activeStatus() == "unpaid") {
      return "Update Payment Info"
    } else {
      return "Active"
    }
  }
  
  endOrDeclinePaymentRequest(type, event) {
    event.preventDefault()
    if (this.state.respondingToPaymentRequest) {
      return null;
    }
    
    let apiCall = null;
    if (type == 'endPay') {
      if (!confirm("Are you sure you want to end this payment agreement")) {
        return null;
      }
      
      apiCall = UsersAssistantsApi.endPayAgreement.bind(UsersAssistantsApi, this.props.joinId, this.state.paymentRequest.id)
    } else {
      if (!confirm("Are you sure you want to decline this payment request")) {
        return null;
      }
      
      apiCall = UsersAssistantsApi.declinePaymentRequest.bind(UsersAssistantsApi, this.props.joinId, this.state.paymentRequest.id)
    }
    
    this.setState({respondingToPaymentRequest: true}, function() {
      apiCall().then(res => {
        this.setState({respondingToPaymentRequest: false, paymentRequest: res.payment_request})
      }, errRes => {
        let newState = {respondingToPaymentRequest: false}
        if (errRes && errRes.responseJSON && errRes.responseJSON.payment_request) {
          newState['paymentRequest'] = errRes.responseJSON.payment_request
        }
        this.setState(newState, function() {
          let message = errRes && errRes.responseJSON ? errRes.responseJSON.message : 'Your request could not be completed'
          alert(message)
        })
      })
    })
  }
    
  paymentRequestInfo() {
    if (!this.state.paymentRequest.id) {
      return null
    } else if (this.state.paymentRequest['unanswered?']) {
      return (
        <div className="assistant-select assistant-select-payment-request">
          <label>Your Virtual Assistant has requested to be paid ${this.state.paymentRequest.pay_amount} weekly</label>
          <a
            href={"/assistant_requests/" + this.props.joinId + "/accept/" + this.props.paymentRequest.id} 
            className="bclick-button bclick-solid-notification-button">Accept</a> 
          
          <button onClick={this.endOrDeclinePaymentRequest.bind(this, 'decline')} className="bclick-button bclick-solid-youtube-red-button">Decline</button>
          
          
        </div>
      )
    } else if (this.state.paymentRequest['declined?']) {
      return (
        <div className="assistant-select assistant-select-payment-request">
          <label>Your Virtual Assistant has requested to be paid ${this.state.paymentRequest.pay_amount} weekly</label>
          <a
            href={"/assistant_requests/" + this.props.joinId + "/accept/" + this.props.paymentRequest.id} 
            style={{opacity: '0.6'}}
            className="bclick-button bclick-solid-notification-button">Change to Accept</a> 
          <button 
            style={{opacity: '0.85'}}
            className="bclick-button bclick-solid-black-button no-hover-change">Declined</button> 
        </div>
      )
    } else if (this.state.paymentRequest['cancelled?']) {
      return (
        <div className="assistant-select assistant-select-payment-request">
          <label>Payment plan has been cancelled</label>
        </div>
      )
    } else if (this.state.paymentRequest['accepted?']) {
      return (
        <div className="assistant-select assistant-select-payment-request">
          <label>{this.props.assistantName} is being paid ${this.state.paymentRequest.pay_amount} weekly</label>
          <a
            style={{opacity: '1.3'}}
            href={"/assistant_requests/" + this.props.joinId + "/accept/" + this.props.paymentRequest.id}
            className="bclick-button bclick-solid-deep-blue-button">{this.activeInputText()}</a> 
          <button 
            style={{opacity: '0.5'}}
            onClick={this.endOrDeclinePaymentRequest.bind(this, 'endPay')}
            className="bclick-button bclick-solid-youtube-red-button">End Billing Agreement</button> 
          {this.activeLabel()}
        </div>
      )
    }
  }

  render() {
    return (
      <div>
        <div className="assistant-select">
          <Select
            clearable={true}
            disabled={this.state.saving}
            value={this.state.assistantId || ''}
            placeholder={this.state.assistantId ? "" : "Add Assistant"}
            options={this.assistantOptions()}
            onChange={this.changeAssistant.bind(this)}/>
        </div>
        <div className="assistant-select assistant-select-response">
          {this.state.response}
        </div>
        
        {this.paymentRequestInfo()}
        
      </div>
    )
  }
  
}


