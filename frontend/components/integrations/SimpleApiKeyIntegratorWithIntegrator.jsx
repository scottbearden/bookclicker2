import React from 'react';
import withIntegrator from './withIntegrator';

class SimpleApiKeyIntegrator extends React.Component {
  
  render() {

    return (
      <div>
      
        {this.props.deleteButton()}
  
        {this.props.saveButton()}
    
        <input 
          className="form-control"
          type="text" 
          onChange={this.props.changeApiKey}
          placeholder={this.props.placeholder || "Api Key"}
          value={this.props.api_key.key || ''}/>
    
        <span className="integration-error">{this.props.errorMessage || ' '}</span>
      
      </div>
    )
  }
  
}

const SimpleApiKeyIntegratorWithIntegrator = withIntegrator(SimpleApiKeyIntegrator);
export default SimpleApiKeyIntegratorWithIntegrator;
  
  