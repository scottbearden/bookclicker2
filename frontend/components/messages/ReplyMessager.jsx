import React from 'react';
import ConversationsApi from '../../api/ConversationsApi';

export default class ReplyMessager extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      message: {
      	body: null
      }
    }
  }

  updateMessageBody(event) {
  	let { message } = this.state;
  	message.body = event && event.target ? event.target.value : null
  	this.setState({message})
  }

  refresher() {
  	return (
      <a href={""} onClick={this.props.refreshConversation.bind(this)} className={"reply-messager-form-toggle btn btn-default open"}>
        <span className="glyphicon glyphicon-refresh"></span>
      </a>
    );
  }

  sendReply(event) {
  	event && event.preventDefault();
    var that = this;

    if (that.state.sending) {
      return null;
    }

    that.setState({sending: true}, () => {
      ConversationsApi.replyToConversation(that.props.conversation.id, that.state.message).then(res => {
        that.setState({message: {}, sending: false}, function() {
          that.props.updateConversation(res.receipts)
        })
      }, errRes => {
        that.setState({sending: false})
        let error = errRes.responseJSON && errRes.responseJSON.error;
        alert(error || "Message did not send")
      })
    })
  	
  }

  form() {
  	return (
  		<form onSubmit={this.sendReply.bind(this)} id="reply-messager-form">

          <div className="reply-form-input">
            <textarea placeholder="Your message here" className="form-control" rows="3" name="body" onChange={this.updateMessageBody.bind(this)} value={this.state.message.body || ""}></textarea>

          </div>

          <div className="reply-form-input">
            {this.refresher()}
            <input type="submit" className="pull-right btn btn-primary" value="Send" disabled={this.state.sending} />
          </div>

        </form>
  	)
  }
  
  render() {

    return (
      <div id="reply-messager">
        {this.form()}
      </div>
    )

  }

}