import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import LaunchPage from './LaunchPage';
import withFlash from '../shared/withFlash';

class LaunchPageApp extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    return (
      <div id="launch-page">
        {this.props.flashMessage()}
        <div>
          <BrowserRouter>
            <div>
              
              <Route path="/my_books/:id(\d+)/launch" render={(props) => (
                <LaunchPage 
                  {...this.props} 
                  {...props} />
              )}>
              </Route>

            </div>
          </BrowserRouter>
        </div>
      </div>
    )
  }
  
}

const LaunchPageAppWithFlash = withFlash(LaunchPageApp);
export default LaunchPageAppWithFlash