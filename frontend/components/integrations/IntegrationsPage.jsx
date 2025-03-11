import React from 'react';
import { hex } from '../../ext/functions';
import OAuthIntegrator from './OAuthIntegratorWithIntegrator';
import SimpleApiKeyIntegrator from './SimpleApiKeyIntegratorWithIntegrator';
import NewIntegrator from './NewIntegrator';
import PageTitle from '../PageTitle';
import withFlash from '../shared/withFlash';

const ALL_PLATFORMS = ['mailchimp', 'aweber', 'mailerlite', 'convertkit']

export default class IntegrationsPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      api_keys: this.props.api_keys
    };
  }
  
  addNewIntegration(platform, platform_nice) {
    let { api_keys } = this.state;
    api_keys.push({platform, platform_nice})
    this.setState({api_keys, has_added_new: true})
  }
  
  integrationStatus(int_status) {
    if (int_status === undefined) {
      return <span><span style={{color: 'grey'}}>loading...</span></span>
    } else if (int_status === null) {
      return <span><span style={{color: 'darkred'}}>Not Integrated</span></span>
    } else if (int_status === "Good") {
      return <span><span style={{color: 'darkgreen'}}>Working</span></span>
    } else if (int_status === "Bad") {
      return <span><span style={{color: 'darkred'}}>Not Working</span></span>
    }
  }
  
  integratorComponent(api_key, idx) {
    let component = null;
    
    if (api_key.platform == "new") {
      return <NewIntegrator key={idx} addNewIntegration={this.addNewIntegration.bind(this)} />
    } else if (api_key.platform == 'mailchimp' || api_key.platform == 'aweber') {
      return <OAuthIntegrator 
                api_key={api_key}
                key={idx}
                integrationStatus={this.integrationStatus.bind(this)}/>
    } else if (api_key.platform == 'mailerlite' || api_key.platform == 'convertkit') {
      return <SimpleApiKeyIntegrator 
                api_key={api_key}
                key={idx}
                placeholder={api_key.platform.capitalize() + ' Api Key'}
                integrationStatus={this.integrationStatus.bind(this)}/>
    } else {
      return null;
    }
  }
  
  integrationsContent() {
    let rows = [];
    
    for (var i = 0; i < this.state.api_keys.length; i++) {
      if (i % 2 === 1) {
        rows.push(
          <div className="integrations-content-row" key={i*100}>
           {[
             this.integratorComponent(this.state.api_keys[i - 1], i*100 + 1),
             this.integratorComponent(this.state.api_keys[i], i*100 + 2)
           ]}
          </div>
        )
      }
    }
    if (this.state.api_keys.length % 2 == 1) {
      rows.push(
        <div className="integrations-content-row" key={i*100}>
         {[
           this.integratorComponent(this.state.api_keys.slice(-1)[0], i*100 + 1),
           this.integratorComponent({platform: "new"}, hex(5))
         ]}
        </div>
      )
    } else {
      rows.push(
        <div className="integrations-content-row new-integration-alone" key={-1}>
         {[
           this.integratorComponent({platform: "new"}, hex(5))
         ]}
        </div>
      )
    }
    
    return rows;
  }

  render() {
    return (
      <div id="integrations-page">
        <PageTitle title={'Api Integrations'} subtitles={[]}/>
        <div className="integrations-content">
          {this.integrationsContent()}
        </div>
      </div>
    )
  }
  
}
