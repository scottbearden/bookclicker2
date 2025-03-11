import React from 'react';
import PageTitle from '../PageTitle';
import PaymentSource from './PaymentSource';
import PaymentInfoApi from '../../api/PaymentInfoApi';
import { hex } from '../../ext/functions';


// todo
// add card with custoer
// add card without customer

export default class PaymentInfoPage extends React.Component {
  
  
  constructor(props) {
    super(props)
    this.state = {
      sources: this.props.customer ? this.props.customer.sources : [], 
      defaultSourceId: this.props.customer && this.props.customer.default_source ? this.props.customer.default_source.id : null
    }
  }
  
  componentDidMount() {
    this.establishDefaultSource()
  }
  
  establishDefaultSource() {
    PaymentInfoApi.getDefaultSource().then(res => {
      this.setState({defaultSourceId: res.default_source_id})
    })
  }
  
  stripeAccountInfo() {
    if (this.props.has_stripe_account) {
      return (
        <div className="pen-name-pill-wrapper no-shadow">
          <div className="pen-name-pill-content">
            <div className="stripe-account-connected"><span>Your Stripe Account is ready for payment</span></div>
          </div>
        </div>
      )
    } else {
      return (
        <div className="stripe-account-not-connected">
          <a href={this.props.connect_with_stripe_link} target="_blank">
            <img src={BookclickerStaticData.connectWithStripeLogo} />
          </a>
        </div>
      )
    }
  }
  
  sources() {
    let paymentSources = this.state.sources.map(source => {
      return <PaymentSource 
                key={source.id} 
                source={source}
                establishDefaultSource={this.establishDefaultSource.bind(this)}
                isDefault={this.state.defaultSourceId && this.state.defaultSourceId == source.id}
                propagateState={this.setState.bind(this)} />
    })
    if (paymentSources.length < BookclickerStaticData.MAX_PAYMENT_SOURCES_PER_CUSTOMER) {
      paymentSources.push(
        <PaymentSource 
          key={"new"} 
          source={{}}
          stripeSetupIntent={this.props.stripe_setup_intent}
          establishDefaultSource={this.establishDefaultSource.bind(this)}
          isDefault={false}
          propagateState={this.setState.bind(this)} />
      )
    }
    return paymentSources;
  }
  
  render() {
    return (
      <div id="clients-page">
        <div id="clients-page-content-wrapper">
          <div id="clients-page-content">
      
            <PageTitle title="Receiving Payments" subtitles={[<span>Receive Payments with <a href={"https://stripe.com/connect"} target="_blank">Stripe Connect</a></span>]}/>
            <div id="stripe-payment-account-info">
              {this.stripeAccountInfo()}
            </div>
            
            <PageTitle title="Making Payments" subtitles={[<span>Manage Payment Info</span>]}/>
        
            {this.sources()}
          </div>
        </div>
      </div>
    )
  }
  

  
  
  
}
