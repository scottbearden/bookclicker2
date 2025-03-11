import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';

import MyListsIndex from './MyListsIndex';
import MyListsShow from './MyListsShow';
import MyListsSelect from './MyListsSelect';


export default class MyListsPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    
    return (
      <div id="my-lists-page">
        <div id="my-lists-page-content">
          <BrowserRouter>
            <div>
            
              <Route path="/my_lists/selections" render={(props) => (
                <MyListsSelect /> 
              )}>
              </Route>
              
              <Route path="/my_lists/:id(\d+)" render={(props) => (
                <MyListsShow {...this.props} {...props} />
              )}>
              </Route>
      
              <Route exact path="/my_lists" render={(props) => (
                <MyListsIndex />
              )}>
              </Route>

            </div>
          </BrowserRouter>
        </div>
      </div>
    )
  }
  
}


