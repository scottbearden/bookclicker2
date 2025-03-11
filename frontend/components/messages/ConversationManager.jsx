import React from 'react';
import ConversationsApi from '../../api/ConversationsApi';
import Tappable from 'react-tappable';

export default class ConversationManager extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      conversation: this.props.conversation
    }
  }

  componentDidMount() {
    $('.conversations-send-to-trash .bootstrap-tooltip').tooltip({placement: 'top'})
  }

  sendToTrash() {
    if (this.state.makingApiCall) {
      return false;
    }

    var that = this;
    that.setState({makingApiCall: true}, function() {
      ConversationsApi.moveToTrash(that.props.conversation.id).then(res => {
        that.setState({conversation: res.conversation, makingApiCall: false})
      })
      
    }, errRes => {
      that.setState({makingApiCall: false});
      alert('Could not delete conversation');
    })
    
  }

  untrash() {
    if (this.state.makingApiCall) {
      return false;
    }

    var that = this;
    that.setState({makingApiCall: true}, function() {
      ConversationsApi.untrash(that.props.conversation.id).then(res => {
        that.setState({conversation: res.conversation, makingApiCall: false})
      })
    }, errRes => {
      that.setState({makingApiCall: false});
      alert('Could not delete conversation');
    })

  }

  moveToTrashButton() {
    return (
      <Tappable 
        style={{display: this.state.conversation.is_trashed ? "none" : "inline-block"}}
        data-tooltip="toggle" title="Move To Trash" disabled={this.state.makingApiCall} className="btn btn-default btn-xs bootstrap-tooltip" onTap={this.sendToTrash.bind(this)}>
        <span className="glyphicon glyphicon-trash"></span>
      </Tappable>
    )
  }

  untrashButton() {
    return (
      <Tappable 
        style={{display: this.state.conversation.is_trashed ? "inline-block" : "none"}}
        data-tooltip="toggle" title="Remove From Trash" disabled={this.state.makingApiCall} className="btn btn-default btn-xs bootstrap-tooltip trashed" onTap={this.untrash.bind(this)}>
        <span className="glyphicon glyphicon-trash"></span>
      </Tappable>
    )
  }

  triggerRefresh(event) {
    $('#conversations-page-conversations').trigger('refresh', {});
    $(event.target).blur()
  }

  refreshButton() {
    return (
      <Tappable 
        disabled={this.state.makingApiCall} id={"refreshConversation" + this.props.conversation.id} className="btn btn-default btn-xs bootstrap-tooltip space-left" onTap={this.triggerRefresh.bind(this)}>
        <span className="glyphicon glyphicon-refresh"></span>
      </Tappable>
    )
  }

  render() {

    return (
      <div className={this.props.index_view ? "conversations-send-to-trash index-view" : "conversations-send-to-trash"}>
        {this.moveToTrashButton()}
        {this.untrashButton()}
        {this.props.index_view ? null : this.refreshButton()}
      </div>
    )
    
  }

}