import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import AssistantPaymentRequestAcceptForm from './AssistantPaymentRequestAcceptForm';
import PageTitle from '../PageTitle';

export default class AssistantPaymentRequestAcceptPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    let title = null;
    let subtitles = []
    if (this.props.assistant && this.props.assistant.full_name_or_email) {
      if (this.props.payment_request['accepted?']) {
        title = 'Update Payment Request'
        subtitles.push("Update payment info for " + this.props.assistant.full_name_or_email)
      } else {
        title = 'Accept Payment Request'
        subtitles.push("Begin payment plan with " + this.props.assistant.full_name_or_email)
      }
    }
    
    return (
      <div id="reservation-page">
        <PageTitle title={title} subtitles={subtitles}/>
        <AssistantPaymentRequestAcceptForm {...this.props} />
      </div>
    )
  }
  
}