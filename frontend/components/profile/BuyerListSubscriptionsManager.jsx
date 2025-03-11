import React from 'react';
import ListSubscriptionsApi from '../../api/ListSubscriptionsApi';
import Toggle from 'react-toggle';

export default class BuyerListSubscriptionsManager extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      listSubscriptions: this.props.listSubscriptions
    }
  }

  subscriptionManagerHtml(subscription, idx) {
    return (
      <div key={idx} className="list-subscription-wrapper">
        <div className="list-subscription">
          <div className="list-subscription-list-name">
            {subscription.list.adopted_pen_name || subscription.list.name} 
            <div className="list-subscribed-since">
              [Since {subscription.subscribed_on}]
            </div>
          </div>

          <label className="to-the-right">
            <div className="space1-2">Subscribed</div>
            <Toggle 
              onChange={this.toggleSubscriptionAction(subscription)}
              checked={subscription["subscribed?"]}/>
          </label>
          <div className="list-subscription-list-size">List Size: {subscription.list.active_member_count_delimited}</div>
          
        </div>
      </div>
    )
  }

  noSubscriptionsHtml() {
    return (
      <div key={1} className="list-subscription-wrapper">
        <div className="list-subscription">
          <div className="list-subscription-list-name">
            {"You have no active list subscriptions.  If you have auto-subscribe on, you will be auto-subscribed to a seller's list as soon as the booking is considered paid."} 
          </div>          
        </div>
      </div>
    )
  }

  updateListSubscription(listSubscriptionId, subscribed) {
    if (this.state.isUnsubscribing) {
      return null;
    }

    this.setState({isUnsubscribing: true}, function() {
      var that = this;
      ListSubscriptionsApi.update(listSubscriptionId, subscribed).then(res => {
        const listSubscriptions = this.state.listSubscriptions.map(listSubscription => {
          if (listSubscription.id == res.list_subscription.id) {
            return res.list_subscription;
          } else {
            return listSubscription;
          }
        });
        this.setState({isUnsubscribing: false, listSubscriptions})
      }, res => {
        this.setState({isUnsubscribing: false})
      })
    })
  }

  optOutButtonCssClasses(subscription) {
    let result = "list-subscription-list-opt-out bclick-button bclick-hollow-light-red-button bclick-xsmall-button";
    if (!subscription["subscribed?"]) {
      result += " bclick-button-disabled is-unsubscribed"
    }
    return result;
  }

  optOutButtonText(subscription) {
    return subscription["subscribed?"] ? "Opt Out" : "Opted Out";
  }

  toggleSubscriptionAction(subscription) {
    if (subscription["subscribed?"]) {
      return this.updateListSubscription.bind(this, subscription.id, false);
    } else {
      return this.updateListSubscription.bind(this, subscription.id, true);
    }
    
  }

  render() {
    let managerDivs = [];
    if (!this.state.listSubscriptions.length) {
      managerDivs.push(this.noSubscriptionsHtml())
    } else {
      this.state.listSubscriptions.forEach((subscription, idx) => {
        let managerDiv = this.subscriptionManagerHtml(subscription, idx);
        managerDivs.push(managerDiv)
      })
    }
    
    return (
      <div id="list-subscriptions-manager" className="profile-input">
        <label className="centerlabel" style={{marginTop: '0px'}}>Active List Subscriptions</label>
        {managerDivs}
      </div>
    )
  }

}