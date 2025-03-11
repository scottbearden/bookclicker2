import React from 'react';
import Toggle from 'react-toggle';
import UsersApi from '../api/UsersApi';

export default class EmailNotificationsToggler extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      subscribed: !!this.props.user[this.props.userField]
    };
  }
  
  toggleEmailNotifications() {
    let apiData = {};
    apiData[this.props.userField] = this.state.subscribed ? 0 : 1;
    var that = this;
    UsersApi.updateEmailSubscribed(apiData).then(res => {
      that.setState({
        subscribed: res[that.props.userField]
      });
    })
  }
  
  render() {
    return (
      <div className="email-notifications-toggler">
        <label className="to-the-right">
          <div className="space1-2">{this.state.subscribed ? 'Subscribed' : 'Unsubscribed'}</div>
          <Toggle 
            onChange={this.toggleEmailNotifications.bind(this)}
            checked={this.state.subscribed}/>
        </label>
      </div>
    )
  }
  
}