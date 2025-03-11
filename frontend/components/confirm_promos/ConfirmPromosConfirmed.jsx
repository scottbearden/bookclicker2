import React from 'react';
import PageTitle from '../PageTitle';
import ConfirmPromoSelect from './ConfirmPromoSelect';
import { Link } from 'react-router-dom';

export default class ConfirmPromosConfirmed extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }
  
  confirmPromoSelects() {
    let result = [];
    if (!this.props.reservations.length) {
      return (
        <div className="confirm-promos-empty">
          <h3 className="error">We could not locate any confirmed promos</h3>
          <div className="big-img-container">
            <img src={BookclickerStaticData.logoWithTextUrl}/>
          </div>
        </div>
       )
    }
    
    this.props.reservations.forEach((reservation, idx) => {
      result.push(<hr key={"hr-" + idx}/>)
      result.push(
        <ConfirmPromoSelect 
          reservation={reservation} 
          book={reservation.book}
          buyer={reservation.buyer}
          seller={this.props.seller} 
          list={reservation.list}
          key={idx}/>
      )
    })
    return result;
  }

  render() {
    return (
      <div>
        <PageTitle 
          title={'Confirmed Promos'} 
          subtitles={
            [
              <a href="/confirm_promos">{"Let's confirm your promo went out"}</a>,
              <b>Previously Confirmed Promotions</b>
            ]
          }/>
        <div id="confirm-promos-selects-wrapper">
          <div id="confirm-promos-selects">
            {this.confirmPromoSelects()}
          </div>
        </div>
      </div>
    )
  }
  
}