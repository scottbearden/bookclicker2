import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import Marketplace from './Marketplace';
import withFlash from '../shared/withFlash';

class MarketplacePage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    return (
      <div id="marketplace-page">
        {this.props.flashMessage()}
        <BrowserRouter>
          <Route path="/marketplace" render={() => (
            <Marketplace is_mobile={this.props.is_mobile}/>
          )}>
          </Route>
        </BrowserRouter>
      </div>
    )
  }
  
}

const MarketplacePageWithFlash = withFlash(MarketplacePage);
export default MarketplacePageWithFlash;