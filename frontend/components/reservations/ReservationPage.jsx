import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import SellerStripeDirective from './SellerStripeDirective';
import AcceptDeclineDirective from './AcceptDeclineDirective';
import RefundDirective from './RefundDirective';
import ReservationInfo from './ReservationInfo';
import PaymentForm from './PaymentForm';
import PageTitle from '../PageTitle';


export default class ReservationPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      stripe_directive: this.props.stripe_directive
    };
  }
  
  render() {
    let title = 'Reservations';
    if (this.props.title) {
      title = this.props.title;
    }
    let subtitles = [];
    if (this.props.accept_decline_directive && this.props.reservation['pending?']) {
      subtitles.push('Please respond to this request')
    }
    
    return (
      <div id="reservation-page">
        <PageTitle title={title} subtitles={subtitles}/>
        <BrowserRouter>
          <div className="reservation-page-banner-container">
            <div className="reservation-page-banner">
          
              <Route path="/reservations/:id(\d+)/info" render={() => (
                <div>
                  <AcceptDeclineDirective propogateState={this.setState.bind(this)} {...this.props} />
                  <RefundDirective {...this.props} />
                  <SellerStripeDirective stripe_directive={this.state.stripe_directive} />
                </div>
              )}/>
              
              <Route path="/reservations/:id(\d+)/pay" render={() => (
                <PaymentForm {...this.props} />
              )}/>
            </div>
          </div>
        </BrowserRouter>
        <ReservationInfo {...this.props} />
      </div>
    )
  }
  
}
