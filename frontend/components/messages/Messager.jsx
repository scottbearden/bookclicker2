import React from 'react';
import ReactDOM from 'react-dom';
import Select from 'react-select';
import ConversationsApi from '../../api/ConversationsApi';


export default class Messager extends React.Component {


  constructor(props) {
    super(props);
    this.state = {
      from_pen_name_id: this.props.my_pen_names.length ? this.props.my_pen_names[0].id : null,
      message_subject: null,
      message_body: null,
      conversation: null,
      link_to_conversation: null
    }
  }

  formFields() {
    return (
      <div>
        <div className="messager-input message-to">
          <label>To</label>
          <input className="form-control" disabled={true} value={this.props.to_obj.pen_name.author_name} type="text" />
        </div>
        <div className="messager-input message-from">
          <label>From</label>
          <Select
            name="pen_name_id"
            required
            clearable={false}
            placeholder={"Pen name to send as"}
            searchable={false}
            disabled={this.props.my_pen_names.length === 1}
            onChange={this.changeFromPenName.bind(this)}
            value={this.state.from_pen_name_id || ''}
            options={this.penNameOptions() || []} />
        </div>
        <div className="messager-input message-subject">
          <label>Subject</label>
          <input required 
            className="form-control" 
            value={this.state.message_subject || ""}
            onChange={this.changeMessageSubject.bind(this)}
            type="text" 
            name="message_subject" />

        </div>
        <div className="messager-input message-body">
          <label>Message</label>
          <textarea required 
            className="form-control" 
            value={this.state.message_body || ""}
            onChange={this.changeMessageBody.bind(this)}
            rows="4" 
            name="message_body" />

        </div>

        <div className="messager-input message-error text-danger">
          {this.state.message_error}
        </div>

        <div className="messager-input message-body">
          <input required className="form-control btn btn-success" type="submit" value="Send Message" disabled={this.state.sending} />

        </div>
      </div>
    )
  }

  changeFromPenName(select) {
    let penNameId = select ? select.value : null;
    this.setState({from_pen_name_id: penNameId})
  }

  changeMessageBody(event) {
    let message_body = event && event.target ? event.target.value : null;
    this.setState({message_body})
  }

  changeMessageSubject(event) {
    let message_subject = event && event.target ? event.target.value : null;
    this.setState({message_subject})
  }

  newConversationData() {
    return {
      message_subject: this.state.message_subject, 
      message_body: this.state.message_body,
      from_pen_name_id: this.state.from_pen_name_id,
      to_pen_name_id: this.props.to_obj.pen_name_id,
      to_user_id: this.props.to_obj.user_id
    }
  }

  sendMessage(event) {
    event.preventDefault();
    var that = this;

    if (that.state.sending) {
      return null;
    } else if (!this.state.message_body) {
      that.setState({message_error: "Message body can't be blank"});
      return null;
    } else if (!this.state.message_subject) {
      that.setState({message_error: "Subject can't be blank"})
      return null;
    }

    that.setState({sending: true, message_error: null}, function() {
      ConversationsApi.startConversation(this.newConversationData()).then(res => {
        that.setState({
          conversation: res.conversation,
          link_to_conversation: res.link_to_conversation,
          sending: false
        })
      }, errRes => {
        that.setState({
          message_error: errRes.responseJSON ? errRes.responseJSON.error : "Something went wrong",
          sending: false
        })
      })
    })

  }

  render() {
    if (this.state.link_to_conversation) {
      return (
        <div className="go-to-conversation">

         <p>
           Your message has been sent successfully.<br/>You may view this conversation by clicking&nbsp;<a target="_blank" href={this.state.link_to_conversation}>here</a>.
         </p>

        </div>
      )

    } else {
      return (
        <div id="start-conversation-form-wrapper">

          <form onSubmit={this.sendMessage.bind(this)} className="start-conversation-form">
            {this.formFields()}
          </form>
        </div>
      )
    }
  }

  penNameOptions() {
    return this.props.my_pen_names.map((pen_name, idx) => {
      return { value: pen_name.id, label: pen_name.author_name }
    })
  }

  static showModal(to_obj, my_pen_names) {
    let $modal = $('#reusableModal');

    if (!to_obj.pen_name) {
      alert('An error has occurred.  Recipient was not found');
      return null;
    }
    
    let modalTitle = "<h4 class='text-center'>Send A Message - <b>" + to_obj.pen_name.author_name + "</b></h4>";

    $modal.find('.modal-header').html(modalTitle)
    let $target = $modal.find('.modal-body').html('<div id="MessagerModal"></div>').find('#MessagerModal')[0]
    ReactDOM.render(
      <Messager
        to_obj={to_obj}
        my_pen_names={my_pen_names} />, $target)
  
    $modal.modal({
      keyboard: true
    })
  }



}