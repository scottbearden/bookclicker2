import React from 'react';
import DashboardBuyerBooksSection from './DashboardBuyerBooksSection';
import DashboardBuyerSentPromosSection from './DashboardBuyerSentPromosSection';
import DashboardBuyerRecentRequestsSection from './DashboardBuyerRecentRequestsSection';

export default class BuyerActivity extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  acceptedPromos() {
    return this.props.recent_book_promos.filter(res => {
      return res["accepted?"] && res.in_past && res["in_buyer_sent_feed?"]
    }).sort((a,b) => {
      return a.date_to_s - b.date_to_s;
    })
  }
  
  requestedPromos() {
    return this.props.recent_book_promos.filter(res => {
      return res["in_buyer_activity_feed?"]
    }).sort((a,b) => {
      return a.date_to_s - b.date_to_s;
    })
  }
  
  render() {
    return (
      <div className="dashboard-activity right">
        <div className="dashboard-activity-header">
          Buyer Activity
        </div>
        <div className="dashboard-activity-content">
          <DashboardBuyerBooksSection books={this.props.books}/>
          <DashboardBuyerSentPromosSection acceptedPromos={this.acceptedPromos()}/>
          <DashboardBuyerRecentRequestsSection requestedPromos={this.requestedPromos()} />
        </div>
      </div>
    )
  }
  
  
}