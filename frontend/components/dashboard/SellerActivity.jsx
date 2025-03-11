import React from 'react';
import DashboardSellerListsSection from './DashboardSellerListsSection';
import DashboardSellerTodaysPromosSection from './DashboardSellerTodaysPromosSection';
import DashboardSellerPendingPromosSection from './DashboardSellerPendingPromosSection';
import DashboardSellerConfirmPromosSection from './DashboardSellerConfirmPromosSection';

export default class SellerActivity extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    return (
      <div className="dashboard-activity left">
        <div className="dashboard-activity-header">
          Seller Activity
        </div>
        <div className="dashboard-activity-content">
      
          <DashboardSellerListsSection 
            lists={this.props.lists}/>
      
          <DashboardSellerTodaysPromosSection 
            lists={this.props.lists} 
            today_in_local_timezone={this.props.today_in_local_timezone}/>
            
          <DashboardSellerPendingPromosSection 
            lists={this.props.lists}/>
            
          <DashboardSellerConfirmPromosSection
            prohibitiveRefundRequest={this.props.prohibitive_refund_request} 
            promosForSendConfirmation={this.props.promos_for_send_confirmation}/>

        </div>
      </div>
    )
  }
  
  
}