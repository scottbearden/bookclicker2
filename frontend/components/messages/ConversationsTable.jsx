import moment from 'moment';
import ReplyMessager from './ReplyMessager';
import React from 'react';
import ConversationsApi from '../../api/ConversationsApi';

export default class ConversationsTable extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      loaded_page_at: Date.now(),
      receipts: this.props.receipts
    }
  }

  componentDidMount() {
    this.listenForRefreshCliks()
  }

  listenForRefreshCliks() {
    var that = this;
    $('#conversations-page-conversations').on('refresh', that.refreshConversation.bind(that))
  }

  refreshConversation(event) {
    event && event.preventDefault && event.preventDefault();
    var that = this;
    ConversationsApi.showConversation(that.props.conversation.id).then(res => {
      that.setState({receipts: res.receipts});
    }, errRes => {
      console.log(errRes)
    })
  }

  updateConversation(receipts) {
    this.setState({receipts})
  }

  asLocaltime(utcText) {
    var localTime  = moment.utc(utcText).toDate();
    if (localTime) {
      return moment(localTime).format('YYYY-MM-DD @ HH:mm');
    }
  }

  senderInfo(message) {
    if (!message || !message.sender) {
      return "?"
    }
    return this.isMine(message) ? this.props.me_pen_name : this.props.them_pen_name;
  }

  isMine(message) {
    return message && message.sender && message.sender.id == this.props.current_member_user_id
  }

  receiptsTds() {

    let result = [];
    this.state.receipts.forEach((receipt, idx) => {
      let message = receipt.message;
      result.push(
        <tr key={receipt.id} className={this.isMine(message) ? 'me read' : 'not-me read'}>
          <td className="width-25 width-10" style={{verticalAlign: 'middle'}}>
            {this.senderInfo(message)}
          </td>
          <td className="width-25">
            {this.isMine(message) ? null : message.body}
          </td>
          <td className="width-25 show-line-breaks">
            {this.isMine(message) ? message.body : null}
          </td>
          <td className="min-100 max-100 not-phone">
            {this.asLocaltime(message ? message.created_at : null)}
          </td>
        </tr>
      )
    });

    return result;
  }

	render() {

    return (
      <table id="conversations-page-conversations" className="table only-80">
        
        <tbody>

          {this.receiptsTds()}

          {!this.state.receipts.length ? <td colspan="100%">This conversation has no messages</td> : null}

          <tr key={"new"} className="me">
            <td className="reply" colSpan="100%">
              <ReplyMessager
                conversation={this.props.conversation}
                receipts={this.state.receipts} 
                refreshConversation={this.refreshConversation.bind(this)}
                updateConversation={this.updateConversation.bind(this)}>
              </ReplyMessager>
            </td>
          </tr>
          
        </tbody>
        
      </table>

    )
    
	}

}