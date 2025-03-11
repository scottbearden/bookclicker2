import React from 'react';
import PageTitle from '../PageTitle';
import ConfirmPromoSelect from './ConfirmPromoSelect';
import { Link } from 'react-router-dom';

export default class ConfirmPromos extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }
  
  confirmPromoSelects() {
    let result = [];
    if (!this.props.reservations.length) {
      return (
        <div className="confirm-promos-empty">
          <h3 className="error">You have no promos to confirm</h3>
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
          title={'Confirm Promos'} 
          subtitles={
            [
              <b>{"Let's confirm your promo went out"}</b>,
              <a href="/confirm_promos/confirmed">Previously Confirmed Promos</a>
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