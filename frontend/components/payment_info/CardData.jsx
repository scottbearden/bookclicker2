import Select from 'react-select';
import React from 'react';

export default class CardData extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {}
  }
  
  render() {
    
    return (
      <div id="card-cardholder-info">
   
         <input 
            type="text" 
            name="name"
            value={this.props.cardData.name || ''}
            onChange={this.props.changeCardData.bind(this, 'name')}
            placeholder="Cardholder's Name"
            className="card-cardholder-name form-control"/>

         <input 
            type="text" 
            name="address_line1"
            value={this.props.cardData.address_line1 || ''}
            onChange={this.props.changeCardData.bind(this, 'address_line1')}
            placeholder="Address Line 1"
            className="card-address-line-1 form-control"/>

         <input 
            type="text" 
            name="address_line2"
            value={this.props.cardData.address_line2 || ''}
            onChange={this.props.changeCardData.bind(this, 'address_line2')}
            placeholder="Address Line 2"
            className="card-address-line-2 form-control"/>

         <input 
            type="text" 
            name="address_city"
            value={this.props.cardData.address_city || ''}
            onChange={this.props.changeCardData.bind(this, 'address_city')}
            placeholder="City"
            className="card-city form-control"/>

         <div className="card-cardholder-info-group">

           <input 
              type="text" 
              name="address_state"
              value={this.props.cardData.address_state || ''}
              onChange={this.props.changeCardData.bind(this, 'address_state')}
              placeholder="State (e.g. NY)"
              className="card-state form-control"/>

           <input 
              type="text" 
              name="address_zip"
              value={this.props.cardData.address_zip || ''}
              onChange={this.props.changeCardData.bind(this, 'address_zip')}
              placeholder="Zip Code"
              className="card-zip form-control"/>

         </div>

         <div className="card-cardholder-info-group">

            <Select 
              clearable={true}
              name="address_country"
              className="card-country"
              value={this.props.cardData.address_country || ''}
              placeholder="Country"
              options={BookclickerStaticData.allCountries}
              onChange={this.props.changeCardAddressCountry}/>

         </div>

      </div>
              
    )
  }
  
  
}


