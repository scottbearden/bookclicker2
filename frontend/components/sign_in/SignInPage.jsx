import React from 'react';
import PageTitle from '../PageTitle';
import SignInForm from './SignInForm';

import { BrowserRouter, Match, Route, Link } from 'react-router-dom';

export default class SignInPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    let title = 'Sign In';    
    return (
      <div>
        <PageTitle title={title} subtitles={[]}  />
        
        <BrowserRouter>
          <div>
            <Route exact path="/login" render={() => (
              <SignInForm/>
            )}>
            </Route>
          </div>
        </BrowserRouter>
        
      </div>
    )
  }
  
}