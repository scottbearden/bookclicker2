import React from 'react';
import IntegrationsApi from '../../api/IntegrationsApi';
import SettleSellerPromosModal from '../shared/SettleSellerPromosModal';

const withIntegrator = (WrappedComponent) => {
  // ...and returns another component...
  return class extends React.Component {
    
    constructor(props) {
      super(props);
      this.state = {
        status: undefined,
        api_key: this.props.api_key,
        saving: false,
        errorMessage: null
      };
    }
  
    componentDidMount() {
      if (this.state.api_key.id) {
        IntegrationsApi.getStatus(this.state.api_key.id).then(res => {
          this.setState({status: res.status})
        })
      } else {
        this.setState({status: null})
      }
    }
    
    changeApiKey(event) {
      let { api_key } = this.state;
      api_key.key = event.target ? event.target.value : null
      this.setState({api_key});
    }
  
    deleteApiKey() {
      if (this.state.deleting) return null;

      let apiCall = null;
      if (this.state.api_key.id && confirm('Please note, without this API key, some functions will not work properly for your active lists.  Would you like to continue?')) {
        apiCall = IntegrationsApi.deleteApiKey.bind(IntegrationsApi, this.state.api_key.id);
      } else {
        return null;
      }

      this.setState({deleting: true}, function() {
        apiCall().then(res => {
          this.setState({deleting: false, status: res.status, api_key: res.api_key, errorMessage: res.destroyMessage || null}, function() {
            if (res.affected_lists && res.affected_lists.length) {
              SettleSellerPromosModal.showModal(res.affected_lists, [], "api integration");
            }
          });
        }, (errA, errB) => {
          let errorMessage = errA.responseJSON ? errA.responseJSON.errorMessage : "Something went wrong";
          let status = errA.responseJSON ? errA.responseJSON.status : "Bad";
          this.setState({deleting: false, status, errorMessage})
        })
      })
    }
    
    saveApiKey() {
      if (this.state.saving) return null;

      let apiCall = null;
      if (this.state.api_key.id) {
        apiCall = IntegrationsApi.updateApiKey.bind(IntegrationsApi, this.state.api_key.id, this.state.api_key.key);
      } else {
        apiCall = IntegrationsApi.createApiKey.bind(IntegrationsApi, this.state.api_key)
      }

      this.setState({saving: true}, function() {
        apiCall().then(res => {
          this.setState({saving: false, status: res.status, api_key: res.api_key, errorMessage: null});
        }, (errA, errB) => {
          let errorMessage = errA.responseJSON ? errA.responseJSON.errorMessage : "Something went wrong";
          let status = errA.responseJSON ? errA.responseJSON.status : "Bad";
          this.setState({saving: false, status, errorMessage})
        })
      })
    }
  
    deleteButton() {
      if (this.state.api_key.id) {
        return (
          <button onClick={this.deleteApiKey.bind(this)} className="pull-left">
            {this.state.deleting ? <span style={{color: 'grey'}}>Deleting...</span> : 'Delete'}
          </button>
        )
      } else {
        return (
          <button className="pull-left" style={{cursor: 'default'}}>
            <span style={{color: 'grey'}}>Delete</span>
          </button>
        )
      }
    }
  
    saveButton() {
      return (
        <button onClick={this.saveApiKey.bind(this)} className="pull-right">
          {this.state.saving ? <span style={{color: 'grey'}}>Saving...</span> : 'Save'}
        </button>
      )
    }
  
    render() {
      
      
      return (
        <div className="integration-box">
          <div className="integration-box-header">{this.state.api_key.platform_nice} Integration</div>
          <div className="integrator api-key-integrator">
      
            <div className="integration-status">{this.props.integrationStatus(this.state.status)}</div>
            <div className="integration-action">
        
              <div className="integration-api-input-container">
        
                <WrappedComponent 
                  api_key={this.state.api_key}
                  changeApiKey={this.changeApiKey.bind(this)}
                  errorMessage={this.state.errorMessage}
                  saveButton={this.saveButton.bind(this)}
                  saveApiKey={this.saveApiKey.bind(this)}
                  deleteButton={this.deleteButton.bind(this)}
                  placeholder={this.props.placeholder}
                  deleteApiKey={this.deleteApiKey.bind(this)} />
                        
              </div>

            </div>
          </div>
        </div>
      )
    }
  }
  
}

export default withIntegrator;
    