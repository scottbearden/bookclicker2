import React from 'react';
import { decimalToPercent, addCommasToNum } from '../../ext/functions';

export default class DashboardSellerListsSection extends React.Component {
  
  constructor(props) {
    super(props);
  }

  listsStats() {
    let result = [];
    if (!this.props.lists.length) {
      return (
        <tr><td className="no-lists" style={{textShadow: 'none'}}>You have no active lists. <a href="/my_lists/selections"><span>Set up lists</span></a></td></tr>
      )
    }
    this.props.lists.forEach((list, idx) => {
      result.push(
        <tr key={idx}>
          <td className="name">{list.adopted_pen_name}</td>
          <td className="stat">{list.active_member_count_delimited}</td>
          <td className="stat">{decimalToPercent(list.open_rate)}</td>
          <td className="stat">{decimalToPercent(list.click_rate)}</td>
          <td className="calendar-link">
            <a href={'/calendars/' + list.id} className="bclick-button bclick-hollow-robin-egg-blue-button">
              <span className="not-phone">CALENDAR</span>
              <span className="phone glyphicon glyphicon-calendar"></span>
            </a>
          </td>
        </tr>

      )

      result.push(
        <tr 
          key={idx.toString() + "-summary"} 
          className="earnings-summary">
          <td colSpan="5">
            So far you have earned ${addCommasToNum(list.total_dollars_paid)} from this list.
          </td>
        </tr>
      )

      result.push(<tr key={idx.toString() + "-space"} className="space-tr"></tr> )
    })
    return result;
  }
  
  render() {
    return (
      <div className="dashboard-activity-section">
        <div className="dashboard-activity-section-header">
          Your Lists
        </div>
        <table className="dashboard-activity-table">
          <tbody>
            {this.listsStats()}
          </tbody>
        </table>

      
      </div>
    )
  }
}
