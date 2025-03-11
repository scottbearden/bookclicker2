import React from 'react';
import { Redirect } from 'react-router';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';

import withFlash from '../shared/withFlash';
import PageTitle from '../PageTitle';
import ConfirmPromos from './ConfirmPromos';
import ConfirmPromosConfirmed from './ConfirmPromosConfirmed';


class ConfirmPromosPage extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }
  
  pendingReservations() {
    return this.props.reservations.filter(res => {
      return !res["send_confirmed?"]
    })
  }
  
  confirmedReservations() {
    return this.props.reservations.filter(res => {
      return res["send_confirmed?"]
    })
  }
  
  render() {
    return (
      <div id="confirm-promos-page">
        {this.props.flashMessage()}
        <BrowserRouter>
          <div>
            
            <Route path="/confirm_promos/confirmed" render={() => (
              <ConfirmPromosConfirmed 
                reservations={this.confirmedReservations()}
                seller={this.props.seller}
                setFlash={this.props.setFlash.bind(this)} />
                
            )}></Route>
  
            <Route exact path="/confirm_promos" render={() => (
              <ConfirmPromos 
                reservations={this.pendingReservations()}
                seller={this.props.seller}
                setFlash={this.props.setFlash.bind(this)} />
                
            )}></Route>
    
          </div>
        </BrowserRouter>
      </div>

    )
  }

}

let ConfirmPromosAppWithFlash = withFlash(ConfirmPromosPage);
export default ConfirmPromosAppWithFlash;