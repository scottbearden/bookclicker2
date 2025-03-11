import React from 'react';
const logoUrl = 'https://s3.ca-central-1.amazonaws.com/bookclicker/check.png';

export default class Benefits extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  benefitLogo() {
    return (<img src={logoUrl} width="30px" height="30px"/>)
  }
  
  blurb1() {
    return "Pay authors in your genre to launch your book to their list."
  }
  
  blurb2() {
    return "Monetize your list and earn goodwill by promoting fellow authors."
  }
  
  blurb3() {
    return "Keep your list engaged.  Improve your also boughts."
  }
  
  render() {
    return (
      <div className="benefits-content">
    
        <div className="benefit-container">
          <div className="benefit">
            <div className="benefit-logo-container">
              {this.benefitLogo()}
            </div>
            
            <div className="benefit-blurb-container">
              <p>
                {this.blurb1()}
              </p>
            </div>
          </div>
        </div>
    
        <div className="benefit-container">
          <div className="benefit">
            <div className="benefit-logo-container">
              {this.benefitLogo()}
            </div>
            
            <div className="benefit-blurb-container">
              <p>
                {this.blurb2()}
              </p>
            </div>
          </div>
        </div>
    
        <div className="benefit-container">
          <div className="benefit">
            <div className="benefit-logo-container">
              {this.benefitLogo()}
            </div>
            
            <div className="benefit-blurb-container">
              <p>
                {this.blurb3()}
              </p>
            </div>
          </div>
        </div>
    
      </div>
    )
  }  
  
}
