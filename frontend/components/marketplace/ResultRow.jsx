import React from 'react';
import { marketplaceFields, marketplaceFieldsWithClass } from '../../constants/misc';
import { decimalToPercent } from '../../ext/functions';
import ListsApi from '../../api/ListsApi';
import MessagerLink from '../messages/MessagerLink';

export default class ResultRow extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  attrFormatted(attr) {
    let val = this.props.attributes[attr];
    let priceAttr = attr.match(/(^.+)_price/);
    if (priceAttr) {
      if (this.props.attributes[priceAttr[1] + "_is_swap_only"]) {
        return <div><div className="desktop">Swap Only</div><div className="not-desktop">Swap</div></div>
      } else if (val > 0 || val == 0) {
        return '$' + val.toString();
      } else {
        return '_'
      }
    } else if (attr == 'author_profile_link_if_verified') {
      if (val) {
        return (
          <div>
            <MessagerLink to_obj={this.props.attributes} myPenNames={this.props.myPenNames} />

            <a href={val} className="amazon-verified-link" target="_blank" data-tooltip="toggle" title="Verified On Amazon">
              <span className="glyphicon glyphicon-ok-circle">
              </span>
            </a>
          </div>
        )
      } else {
        return (
          <div>
            <MessagerLink to_obj={this.props.attributes} myPenNames={this.props.myPenNames} />
          </div>
        )
      }
    } else if (!val && val !== 0) {
      return "_"
    } else if (attr == 'open_rate' || attr == 'click_rate') {
      return decimalToPercent(val);
    } else {
      return val;
    }
  }
  
  rateList(rating) {
    if (this.state.makingApiCall) return null;
    
    if (rating == this.props.rating) {
      rating = null;
    }
    
    this.setState({makingApiCall: true}, function() {
      ListsApi.rateList(this.props.attributes.id, rating).then(res => {
        this.setState({makingApiCall: false}, function() {
          this.props.updateRating(res.list_rating)
        })
      }, errRes => {
        this.setState({makingApiCall: false})
      })
    })
  }
  
  bookingCalendarUrl() {
    let result = "/booking_calendar/" + this.props.attributes.id;
    let start_date_regex = this.props.start_date && this.props.start_date.match(/(\d{4})-(\d{2})-\d{2}/)
    
    if (start_date_regex) {
      let month = parseInt(start_date_regex[2])
      let year = parseInt(start_date_regex[1])
      result += "?month=" + month + "&year=" + year;
      if (this.props.preselected_book_id) {
        result += "&preselected_book_id=" + this.props.preselected_book_id;
      }
    } else if (this.props.preselected_book_id) {
      result += "?preselected_book_id=" + this.props.preselected_book_id
    }
    
    return result
  }
  
  render() {
    
    let tds = [];
    
    tds.push(
      <td className="marketplace-results-actions narrow" key={"rating-actions"}>
        <div className="thumbs-up-down-rating-wrapper">
          <div className={"thumbs-up-down-rating" + (this.props.rating == 1 ? " is-list-rating" : "")} onClick={this.rateList.bind(this, 1)}>
            <a className="glyphicon glyphicon-thumbs-up"></a>
          </div>
          
          <div className={"thumbs-up-down-rating" + (this.props.rating == -1 ? " is-list-rating" : "")} onClick={this.rateList.bind(this, -1)}>
            <a className="glyphicon glyphicon-thumbs-down"></a>
          </div>  
        </div>
      </td>
    )
    
    marketplaceFields.forEach((attr, idx) => {
      tds.push(
        <td key={idx} className={marketplaceFieldsWithClass[attr]}>
          {this.attrFormatted(attr)}
        </td>
      )
    })
    
    let props = {};
    let extraCssClass = "";
    if (!this.props.attributes.inventories.length) {
      props = { onClick: e => e.preventDefault()}
      extraCssClass = "disabled";
    } 
    
    tds.push(
      <td className="marketplace-results-actions med-narrow" key="actions">
        <a 
          className={"bclick-button bclick-solid-robin-egg-blue-button " + extraCssClass}
          {...props}
          href={this.bookingCalendarUrl()}>Book</a>
      </td>
    );
    
    return (
      <tr className="marketplace-results-row">
        {tds}
      </tr>
    )
  }
  
}
