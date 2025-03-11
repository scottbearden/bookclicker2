import React from 'react';
import DatePicker from 'react-datepicker';
import moment from 'moment';

export default class MarketplaceDateFilter extends React.Component {
  
  
  constructor(props) {
    super(props);
    this.state = {
      start_date: this.props.start_date,
      end_date: this.props.end_date
    }
  }
  
  clearDate(field) {
    let stateUpdate = {}
    stateUpdate[field] = undefined;
    this.setState(stateUpdate, function() {
      this.props.updateDate(stateUpdate)
    })
  }

  render() {
    return (
      <div className="genre-select-wrapper">
        <label className="marketplace-filter-header">{"Dates Available"}</label>
        
        <div className="date-selectors">
          
          <div className="date-selector left">
            <label className="small-date-selector-label">
              Available after
              <a 
                 style={{display: this.props.start_date ? "inline-block" : "none"}}
                 className={"small-date-selector-clear" + (this.props.is_mobile ? " mobile" : "")} 
                 onClick={this.clearDate.bind(this, 'start_date')}>
                <span>{this.props.is_mobile ? "(clear)" : "clear"}</span>
              </a>
            </label>
            {this.dateSelector('start_date')}
          </div>
         
          <div className="date-selector right">
            <label className="small-date-selector-label">
              Available before
              <a 
                 style={{display: this.props.end_date ? "inline-block" : "none"}}
                 className={"small-date-selector-clear" + (this.props.is_mobile ? " mobile" : "")} 
                 onClick={this.clearDate.bind(this, 'end_date')}>
                <span>{this.props.is_mobile ? "(clear)" : "clear"}</span>
              </a>
            </label>
            {this.dateSelector('end_date')}
          </div>
      
        </div>
          
      </div>
    )
  }
  
  changeDateState(field, event) {
    let newState = {}
    newState[field] = (event && event.target.value) || undefined
    this.setState(newState)
  }
  
  updateDate(field) {
    let stateUpdate = {}
    stateUpdate[field] = this.state[field]
    this.props.updateDate(stateUpdate)
  }
  
  updateDatePicker(field, dateMoment) {
    let stateUpdate = {}
    stateUpdate[field] = dateMoment ? dateMoment.format('YYYY-MM-DD') :  undefined;
    this.props.updateDate(stateUpdate)
  }
  
  componentDidUpdate(prevProps) {
    if (this.refs.start_date_input && this.refs.end_date_input) {
      this.refs.start_date_input.defaultValue = "";
      this.refs.end_date_input.defaultValue = "";
    }
  }
  
  dateSelector(field) {
    let placeholder = field == "start_date" ? "Available from" : "Available until";
    
    
    if (this.props.is_mobile) {
      return (
        <input
          type="date"
          ref={field + "_input"}
          className={"form-control mobile-device"}
          placeholder={!this.state[field] ? placeholder : null}
          value={this.state[field] || ''}
          onChange={this.changeDateState.bind(this, field)}
          onBlur={this.updateDate.bind(this, field)}/>
      )
    } else {
      return (
        <DatePicker
          selected={this.props[field] ? moment(this.props[field]) : ''}
          dateFormat="MMMM Do, YYYY"
          className="form-control"
          placeholderText={!this.props[field] ? placeholder : null}
          onChange={this.updateDatePicker.bind(this, field)} />
      )
    }
  }
  
}
