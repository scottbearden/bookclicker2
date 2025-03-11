import React from 'react';
import Messager from '../messages/Messager';
import Tappable from 'react-tappable';

export default class MessagerLink extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }

  openMessager(event) {
    event.preventDefault();
    Messager.showModal(this.props.to_obj, this.props.myPenNames);
  }

  render() {

    return (
      <Tappable onTap={this.openMessager.bind(this)} className="amazon-verified-link" data-tooltip="toggle" title={this.props.tooltipTitle || "Send Message"}>
        <img src="https://s3.ca-central-1.amazonaws.com/bookclicker/chat-bubble-logo-icon-74378.png" width="25px;">
        </img>
      </Tappable>
    )

  }


}