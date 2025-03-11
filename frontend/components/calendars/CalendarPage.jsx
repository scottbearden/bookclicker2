import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';
import PageTitle from '../PageTitle';
import Calendar from './Calendar';

export default class CalendarPage extends React.Component {


  render() {
    let subtitles = []
    subtitles.push(this.props.list.adopted_pen_name)
    if (this.props.list.active_member_count_delimited) {
      subtitles.push(this.props.list.active_member_count_delimited + " active subscribers.")
    }
    
    return (
      <div id="calendar-page">
        <BrowserRouter>
          <Route path="/calendars/:id(\d+)" render={() => (
            <div>
              <PageTitle title={"Your Calendar"} subtitles={subtitles} />
              <div className="set-your-inventory-wrapper">
                <a 
                  className="bclick-button bclick-hollow-grey-button set-your-inventory"
                  href={'/my_lists/' + this.props.list.id}>
                  <span>Set Your Inventory</span>
                </a>
              </div>
              <Calendar list={this.props.list} isMobile={this.props.is_mobile} seller={this.props.seller}/>
            </div>
          )}>
          </Route>
        </BrowserRouter>
     </div>
    )
    
  } 
}