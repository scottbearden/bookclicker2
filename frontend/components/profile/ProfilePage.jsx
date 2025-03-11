import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import Profile from './Profile';

export default class ProfilePage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    return (
      <div id="profile-page">
        <BrowserRouter>
          <Route path="/profile" render={() => (
            <Profile {...this.props}/>
          )}>
          </Route>
        </BrowserRouter>
      </div>
    )
  }
  
}