import React from 'react';


const PLATFORMS_FORMATTED = {
  mailchimp: "MailChimp",
  mailerlite: "MailerLite",
  aweber: "AWeber",
  convertkit: "ConvertKit"
};

export default class NewIntegrator extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  makeSelection(event) {
    let platform = event.target.value;
    let platform_nice = PLATFORMS_FORMATTED[platform]
    if (platform_nice) {
      this.props.addNewIntegration(platform, platform_nice)
    }
    this.setState({selection: null})
  }
  
  render() {

    return (
      <div className="integration-box">
        <div className="integration-box-header">Add New Integration</div>
        <div className="integrator">
          <div className="integration-status wide-only">&nbsp;</div>
          <div className="integration-action">
            <div className="integration-api-input-container">
      
              <button className="pull-left" style={{cursor: 'default', backgroundColor: 'white', border: 'white'}}>
                <span style={{color: 'white'}}>Delete</span>
              </button>
      
              <select value={this.state.selection || ''} className='form-control' onChange={this.makeSelection.bind(this)}>
                <option value="">Select Mailing Platform</option>
                <option value="mailchimp">MailChimp</option>
                <option value="aweber">AWeber</option>
                <option value="mailerlite">MailerLite</option>
                <option value="convertkit">ConvertKit</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    )
  }
  
}
  
  