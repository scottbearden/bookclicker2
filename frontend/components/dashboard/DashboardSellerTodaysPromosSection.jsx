import React from 'react';
import MessagerLink from '../../components/messages/MessagerLink';

export default class DashboardSellerTodaysPromosSection extends React.Component {
  
  constructor(props) {
    super(props);
  }
  
  listPromos(list) {
    let system = list.reservations_today;
    let manual = list.external_reservations_today;
    return system.concat(manual)
  }
  
  componentDidMount() {
    $('.todays-promos-tooltips').tooltip()
  }

  listsAndTheirPromos() {
    let lists = this.props.lists.filter(list => this.listPromos(list).length )
    if (!lists.length) {
      return (
          <div className="todays-promos-list">
            <div className="todays-promos-list-header">
              You have no promos scheduled for today
            </div>
          </div>
      )
    }
    let result = [];
    lists.forEach((list, idx) => {
      result.push(
        <div key={idx} className="todays-promos-list">
          <div className="todays-promos-list-header">
            Today you are promoting as&nbsp;{list.pen_name.author_name}:
          </div>

          <div className="todays-promos-list-promos">
            {this.expandPromosForList(list)}
          </div>

        </div>

      )
    })
    return result;
  }
  
  onDetailsClick(isInternal, event) {
    if (!isInternal) {
      event.preventDefault()
    }
  }
  
  onDetailsHover(reservation) {
    return "You have a " + reservation.inv_type + " scheduled today for " + (reservation.book_owner_email || reservation.book_author);
  }

  expandPromosForList(list) {
    var promos = this.listPromos(list);
    return promos.map((reservation, idx) => {
      return (
        
        <table className="dashboard-activity-table" key={idx}>
          <tbody>
            <tr key={idx} className="todays-promos-list-promo">
              <td className="no-text-shadow name-only">
                {reservation.book_title || reservation.book_author} as a {reservation.inv_type}.
              </td>
              
              <td className="no-text-shadow stat">
                { 
                  reservation.internal && list.pen_name ? 
                   <MessagerLink to_obj={reservation.book} 
                                 tooltipTitle={"Send message to " + reservation.book_author}
                                 myPenNames={[{id: list.pen_name.id, author_name: list.pen_name.author_name}]} /> : null
                }
              </td>
              <td className="no-text-shadow stat"></td>
              <td className="no-text-shadow stat"></td>
              
              <td className="promo-sent-link">
                <a 
                  href={reservation.internal ? ("/reservations/" + reservation.id + "/info") : ""}
                  onClick={this.onDetailsClick.bind(this, reservation.internal)}
                  title={this.onDetailsHover(reservation)}
                  data-toggle="tooltip"
                  target="_blank"
                  className="bclick-button bclick-hollow-robin-egg-blue-button todays-promos-tooltips">
                  {reservation.internal ? "DETAILS" : "---"}
                </a>
              </td>
            </tr>
          </tbody>
        </table>
        
      )
    })
  }
  
  render() {
    return (
      <div className="dashboard-activity-section extra-20">
        <div className="dashboard-activity-section-header">
          {"Today's Promos - " + this.props.today_in_local_timezone}
        </div>

        <div className="dashboard-activity-section-content">
          {this.listsAndTheirPromos()}
        </div>
      
      </div>
    )
  }
}
