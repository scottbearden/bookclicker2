import React from 'react';

export default class MarketplaceSearch extends React.Component {
  constructor(props) {
    super(props);
    this.state = { searchInputValue: this.props.search };
  }
  
  handleSubmit() {
    this.props.changeHandler(this.state.searchInputValue);
  }
  
  updateSearchInputValue(event) {
    this.setState({searchInputValue: event.target.value});
  }
  
  _handleKeyPress(event) {
    if (event.charCode == 13) {
      this.handleSubmit()
    }
  }
  
  render() {
    return (
      <div className="marketplace-search-container">
        <div className="marketplace-search-content">
          <div className="marketplace-search-input-container">
            <span className="glyphicon glyphicon-search"></span>
            <input 
              id="marketplace-search-input" 
              value={this.state.searchInputValue || ''}
              onChange={this.updateSearchInputValue.bind(this)}
              onKeyPress={this._handleKeyPress.bind(this)}
              type="text"></input>
            <input 
              id="marketplace-search-submit" 
              className="bclick-button bclick-solid-robin-egg-blue-button"
              type="submit" 
              onClick={this.handleSubmit.bind(this)}
              value="&nbsp;SEARCH"></input>
          </div>
        </div> 
      </div>
    )
  }
}
