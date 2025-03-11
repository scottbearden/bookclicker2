import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';

import PenNamesIndexWithPenNameStuff from './PenNamesIndexWithPenNameStuff';
import PenNamesSharingWithPenNameStuff from './PenNamesSharingWithPenNameStuff';
import withFlash from '../shared/withFlash';

class PenNamesApp extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    
    return (
      <div id="pen-names-page">
        {this.props.flashMessage()}
        <div id="pen-names-page-content">
          <BrowserRouter>
            <div>
              
              <Route exact path="/pen_names" render={(props) => (
                <PenNamesIndexWithPenNameStuff 
                  currentMemberUserId={this.props.current_member_user_id}
                  pen_names={this.props.pen_names}
                  pen_name_requests={this.props.pen_name_requests}
                  pen_name_groups={this.props.pen_name_groups}
                  setFlash={this.props.setFlash} />
              )}>
              </Route>
              
              <Route exact path="/pen_names/sharing" render={(props) => (
                
                <PenNamesSharingWithPenNameStuff 
                  currentMemberUserId={this.props.current_member_user_id}
                  pen_name_requests={this.props.pen_name_requests}
                  pen_name_groups={this.props.pen_name_groups}
                  setFlash={this.props.setFlash}/>
                  
              )}>
              </Route>

            </div>
          </BrowserRouter>
        </div>
      </div>
    )
  }
  
}

const PenNamesAppWithFlash = withFlash(PenNamesApp);
export default PenNamesAppWithFlash