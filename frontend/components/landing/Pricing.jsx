import React from 'react';
import { Link } from 'react-router-dom';

const fullMemberPoints = [
  {
    title: 'BUY & SELL',
    caption: 'Participate fully in the marketplace.  Buy and sell promo.'
  },
  {
    title: 'BUILD COMMUNITY',
    caption: "Build goodwill by promoting others.  They'll sell to you if you sell to them."
  },
  {
    title: 'GET RICHER',
    caption: "Sell promo when you're not launching.  Buy it back when you are."
  },
  {
    title: 'OUR FEE',
    caption: "We take a 10 percent transaction fee when you sell a promo for cash.  Swaps are free."
  }
]

export default class Pricing extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  pricingFlyerHeaderHtml(role) {
    return (
      <div className="pricing-flyer-header-container">
        <div className="pricing-flyer-header">
          {role}
        </div>
      </div>
    )
  }
  
  pricingPriceHtml(priceText) {
    return (
      <div className="pricing-price-container">
        <div className="pricing-price-per-month-container">
          <div className="pricing-price-per-month">
            <b>Our Fee</b>
            <br/>
            We take a 10 percent transaction fee when you sell a promo for cash.
            <br/>
            Swaps are free.
          </div>
        </div>
      </div>
    )
  }
  
  pricingFlyerPointHtml(data) {
    return (
      <div className="pricing-flyer-point">
        <div className="pricing-flyer-point-title-container">
          <div className="pricing-flyer-point-title">
            {data.title}
          </div>
        </div>
        <div className="pricing-flyer-point-caption-container">
          <div className="pricing-flyer-point-caption">
            {data.caption}
          </div>
        </div>
      </div>
    )
  }
  
  render() {
    return (
      <div className="pricing-content">
                    
        <div className="pricing-flyer-container">
          <div className="pricing-flyer pricing-flyer-highlighted">
            {this.pricingFlyerHeaderHtml('FULL MEMBER')}

            <div className="pricing-flyer-body-container">
              <div className="pricing-flyer-body">
                {this.pricingFlyerPointHtml(fullMemberPoints[0])}
                {this.pricingFlyerPointHtml(fullMemberPoints[1])}
                {this.pricingFlyerPointHtml(fullMemberPoints[2])}
                {this.pricingFlyerPointHtml(fullMemberPoints[3])}
            
                <div className="pricing-choose">
                  <a 
                    className="bclick-button bclick-hollow-grey-button bclick-no-text-transform-button"
                    href={"/sign_up#landing-slider"}>
                    Create Free Account
                  </a>
                </div>
            
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }  
}


