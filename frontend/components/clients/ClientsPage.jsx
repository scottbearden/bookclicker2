import React from 'react';
import PageTitle from '../PageTitle';
import ClientManager from './ClientManager';

export default class ClientsPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      clientConnections: this.props.client_connections
    }
  }
  
  clients() {
    if (!this.state.clientConnections.length) {
      return (
        <div className="clients-empty">
          <h3 className="error">You are not connected to any accounts</h3>
          <div className="big-img-container">
            <img src={BookclickerStaticData.logoWithTextUrl}/>
          </div>
        </div>
      )
    }
    return this.state.clientConnections.map(connection => {
      return <ClientManager key={connection.id} connection={connection}/>
    })
  }
  
  render() {
    return (
      <div id="clients-page">
        <PageTitle title="Managed Accounts" subtitles={["Manage Payment Plans"]}/>
        <div id="clients-page-content-wrapper">
          <div id="clients-page-content">
            {this.clients()}
          </div>
        </div>
      </div>
    )
  }
  
}