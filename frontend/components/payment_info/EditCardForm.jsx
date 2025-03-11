import React from 'react';
import CardData from './CardData';
import { grabCsrfToken } from '../../ext/functions';

export default class EditCardForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      cardData: this.props.card
    };
  }
  
  changeCardAddressCountry(selection) {
    let { cardData } = this.state;
    cardData.address_country = selection ? selection.value : null;
    this.setState({cardData});
  }
  
  changeCardData(field, event) {
    let { cardData } = this.state;
    cardData[field] = event ? event.target.value : null;
    this.setState({cardData});
  }
  
  render() {

    return (
      <div className="edit-card-form-container" style={{marginTop: '0px'}}>
        <form action={"/payment_infos/" + this.props.card.id } method="post" className="edit-card-form">
          <input type="hidden" name="_method" value="PUT" />
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
      
          <div className="form-row">
            <div className="payment-form-info">
      
              <CardData 
               cardData={this.state.cardData}
               changeCardData={this.changeCardData.bind(this)}
               changeCardAddressCountry={this.changeCardAddressCountry.bind(this)}/>
             
             </div>
          
          </div>
               
          <div className="form-row cancel-or-update">
               
             <a 
               onClick={this.props.cancelEditingCard}
               className="bclick-button bclick-hollow-youtube-red-button">Cancel</a>
               
               &nbsp;&nbsp;&nbsp;
             
             <input 
               type="submit"
               value="Update Card"
               className={"bclick-button bclick-solid-mailchimp-gray-button"}/>
               
          </div>
             
        </form>
      </div>
    )
  }
  
}
