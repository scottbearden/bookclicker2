 import React from 'react';
import SellerActivity from './SellerActivity';
import BuyerActivity from './BuyerActivity';

export default class Dashboard extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    return (
      <div id="dashboard">
        <div className="dashboard-intro-wrapper">
          <div className="dashboard-intro">
            <div className="dashboard-intro-greeting">
              {this.props.greeting}
            </div>
            <div className="dashboard-intro-text">
              Welcome to your Bookclicker dashboard.  Here you can set up your lists and books, buy promo on the marketplace, and plan your launches.
            </div>
          </div>
        </div>
        
        <div className="space1">&nbsp;</div>
        <div className="space1">&nbsp;</div>
        
        <div className="dashboard-activity-wrapper">
          <SellerActivity {...this.props}/>
          <BuyerActivity {...this.props}/>
        </div>

      </div>
    )
  }

  componentDidMount() {
    $('.amazon-verified-link').tooltip({html: true, position: 'top'})
  }
  
  
}