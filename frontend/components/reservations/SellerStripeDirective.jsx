import React from 'react';
export default class SellerStripeDirective extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    
    let stripe_div = ""
    if (this.props.stripe_directive) {
      stripe_div = (
        <div className="connect-with-stripe-container">
          <a href={this.props.stripe_directive.link} target="_blank">
            <img className="powered-by-stripe-img" src={BookclickerStaticData.connectWithStripeLogo2x}/>
          </a>
          <div className="connect-with-stripe-notice">{this.props.stripe_directive.message}</div>
        </div>
      )
    }
    return (
      <div>
        {stripe_div}
      </div>
    )
  }
}