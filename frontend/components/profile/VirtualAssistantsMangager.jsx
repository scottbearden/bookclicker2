import React from 'react';
import VirtualAssistantForm from './VirtualAssistantForm';
import { hex } from '../../ext/functions';

export default class VirtualAssistantsManager extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      users_assistants: this.props.users_assistants
    }
  }

  render() {
    return (
      <div style={{marginBottom: '40px'}}>
        {this.currentAssistantsForms()}
        {this.newAssistantForm()}
      </div>
    )
  }
  
  rerenderVirtualAssistantManager(users_assistants) {
    this.setState({users_assistants})
  }
  
  currentAssistantsForms() {
    return []
  }
  
  currentAssistantsForms() {
    return this.state.users_assistants.map(join_record => {
      return (
        <VirtualAssistantForm 
          rerenderVirtualAssistantManager={this.rerenderVirtualAssistantManager.bind(this)}
          all_assistants={this.props.all_assistants} 
          joinId={join_record.id}
          assistantId={join_record.assistant.id} 
          assistantName={join_record.assistant.full_name_or_email}
          paymentRequest={join_record.payment_request_json}
          key={join_record.id} />
      )
    })
  }
  
  newAssistantForm() {
    return (
      <VirtualAssistantForm 
        rerenderVirtualAssistantManager={this.rerenderVirtualAssistantManager.bind(this)}
        all_assistants={this.props.all_assistants}
        paymentRequest={{}}
        key={hex(40)} />
    )
  }
   
}
