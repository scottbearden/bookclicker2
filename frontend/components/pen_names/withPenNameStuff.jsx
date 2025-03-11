import React from 'react';
import { grabCsrfToken, scrollToHash } from '../../ext/functions';
import PenNamesApi from '../../api/PenNamesApi';

const withPenNameStuff = (WrappedComponent) => {
  // ...and returns another component...
  return class extends React.Component {

    constructor(props) {
      let hash = document.location.hash;
      super(props);
      this.state = {
        penNames: this.props.pen_names || [],
        penNameGroups: this.props.pen_name_groups || [],
        penNameRequests: this.props.pen_name_requests || [],
        hash: hash
      };
    }
    
    verifiedStatusContent(pen_name) {
      if (pen_name.verified) {
        return (
          <a href={pen_name.author_profile_url} target="_blank">
            <img className="amazon-logo" src={BookclickerStaticData.amazonLogoUrl}/> verified
          </a>
        )
      }
    }
    
    componentDidMount() {
      var that = this;
      this.reloadPenNames(function() {
        scrollToHash(that.state.hash, $)  
      });
    }

    reloadPenNames(callback) {
      PenNamesApi.getPenNamesWithBooks().then(res => {
        this.setState({
          penNames: res.pen_names, 
          penNameGroups: res.pen_name_groups,
          penNameRequests: res.pen_name_requests}, function() {
          callback && callback()
        })
      })
    }

    render() {
      return (
        <WrappedComponent 
          {...this.props} 
          {...this.state}
          verifiedStatusContent={this.verifiedStatusContent.bind(this)}
          reloadPenNames={this.reloadPenNames.bind(this)}
          setWrapperState={this.setState.bind(this)} />);
    }
  };
}

export default withPenNameStuff;