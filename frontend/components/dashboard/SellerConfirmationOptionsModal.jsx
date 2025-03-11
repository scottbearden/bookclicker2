import React from 'react';

export default class SellerConfirmationOptionsModal extends React.Component {
  
  
  constructor(props) {
    super(props);
    this.state = {
      reservation: this.props.reservation
    };
  }
  
  render() {
    
    return (
      <div className="not-sent-confirmation-options">
        <h4 style={{textAlign: 'center', marginBottom: '30px'}}>What would you like to do?</h4>
        <div className="not-sent-confirmation-options-options">
      
          <div className={"not-sent-confirmation-options-option half"}>
            <a 
               href={"/confirm_promos?resId=" + this.props.reservation.id} 
               target="_blank" 
               className="bclick-button bclick-solid-robin-egg-blue-button">
              Confirm Promo
            </a>
      
          </div>
               
          <div className={"not-sent-confirmation-options-option half"}>
            <a 
               href={"/reservations/" + this.props.reservation.id + "/info?withRefundLink=true"} 
               target="_blank" 
               className="bclick-button bclick-solid-youtube-red-button">
              Issue Refund
            </a>
          </div>
      
        </div>
      </div>
    )
  }
  
  
}
