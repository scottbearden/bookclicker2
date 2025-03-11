import React from 'react';
import { Redirect } from 'react-router';
import { Link } from 'react-router-dom';
import withFlash from '../shared/withFlash';
import Dashboard from './Dashboard';

class DashboardApp extends React.Component {
  
  constructor(props) {
    super(props);
  }
  
  render() {

    return (
      <div id="dashboard-app">
        {this.props.flashMessage()}
        <Dashboard {...this.props}/>
      </div>
    )

  }

}

const DashboardAppWithFlash = withFlash(DashboardApp);
export default DashboardAppWithFlash;