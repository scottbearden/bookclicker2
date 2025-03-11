import React from 'react';
import ClientPaymentRequestForm from './ClientPaymentRequestForm';
import { hex } from '../../ext/functions';
import { iOS } from '../../ext/userAgent';


export default class ClientManager extends React.Component {
  
  
  constructor(props) {
    super(props);
    this.state = {
      connection: this.props.connection,
      sendResponse: null,
      payRequestsOpen: this.hasSentPaymentRequests(true)
    }
  }
  
  paymentRequestsForms() {
    if (!this.showPayRequestsTool()) return null;
    
    return this.state.connection.payment_requests_json.map(payment_request => {
      return <ClientPaymentRequestForm 
        connectionId={this.state.connection.id} 
        key={payment_request.id || hex(5)}
        payment_request={payment_request}
        propogateState={this.setState.bind(this)}/>
    })
  }
  
  hasSentPaymentRequests(useProps) {
    let { payment_requests_json } = useProps ? this.props.connection : this.state.connection
    return payment_requests_json.filter(payment_request => {
      return !!payment_request.id
    }).length
  }
  
  blankThird() {
    return (
      <div className="pen-name-pill-item blank-third">
        <div className="pen-name-pill-item-content">
          &nbsp;
        </div>
      </div>
    )
  }
  
  showPayRequestsTool() {
    return this.state.payRequestsOpen || this.hasSentPaymentRequests();
  }
  
  togglePayRequestsTool(event) {
    if (!this.hasSentPaymentRequests()) {
      this.setState({payRequestsOpen: event.target.checked, togglePayRequestsToolBlock: null})
    }
  }
  
  groupPenNameSelect() {
    return (
      <div className='clearfix'>
        <div className="enter-amazon-profile-text smaller">Receive Pay Via Stripe</div>
        
        {this.blankThird()}
        <div className={"pen-name-pill-item center-input" + (!!this.state.togglePayRequestsToolBlock ? " more-height" : "") }>
          <div className={"pen-name-pill-item-content has-checkbox" + (iOS() ? " ios" : "")}>
            <input type="checkbox" 
              checked={this.showPayRequestsTool()} 
              disabled={this.hasSentPaymentRequests()}
              onChange={this.togglePayRequestsTool.bind(this)} />
              
            <div 
              className="client-manager-pay-toggle-block"
              dangerouslySetInnerHTML={{__html: this.state.togglePayRequestsToolBlock }}
              ></div>
          </div>
        </div>
        {this.blankThird()}
      </div>
    )
  }
  
  render() {
    return (
      <div className="pen-name-pill-wrapper">
        <div className="pen-name-pill-content">
        
          {this.blankThird()}
          <div className="pen-name-pill-item center-input">
            <div className="pen-name-pill-item-content">
              <div className="pen-name-header">{this.state.connection.user.assisting_display_name}</div>
            </div>
          </div>
          {this.blankThird()}
          <div className='space1'/>
          
          {this.groupPenNameSelect()}
          
          {this.paymentRequestsForms()}
          
        </div>
      </div>
    )
  }
  
}