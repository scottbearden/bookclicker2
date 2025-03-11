import React from 'react';
import { BarChart, XAxis, YAxis, CartesianGrid, Tooltip, Legend, Bar, ResponsiveContainer } from 'recharts';
import moment from 'moment';
import PageTitle from '../PageTitle';
import MyBooksShow from '../my_books/MyBooksShow'; 
import MyBooksApi from '../../api/MyBooksApi';
import Marketplace from '../../components/marketplace/Marketplace';
import { Redirect } from 'react-router';
import Select from 'react-select';
import { grabCsrfToken } from '../../ext/functions';

export default class LaunchPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      editMode: false,
      books: this.props.books,
      data_for_chart: this.props.data_for_chart,
      data_for_chart_book_id: this.bookId(),
      promos: this.props.promos
    }
  }
  
  chartData() {
    return this.state.data_for_chart.map(date => {
      return { 
        date: moment(date.date).format('MMM D'),
        total: date.num_emails,
        solo: date.solos,
        feature: date.features,
        mention: date.mentions
      }
    });
  }
  
  componentDidUpdate() {
    if (this.state.data_for_chart_book_id === this.bookId()) {
      return null;
    }
    MyBooksApi.loadLaunchData(this.bookId()).then(res => {
      console.log('loading chart data')
      this.setState({
        data_for_chart: res.data_for_chart, 
        data_for_chart_book_id: res.book_id,
        books: res.books,
        promos: res.promos })
    })
  }
  
  cancelAction(promo) {
    if (promo['cancellable_swap?']) {
      return (
        <form action={"/reservations/" + promo.id + "/cancel_swap_as_buyer"} method='POST' onSubmit={e => { if (!confirm('Are you sure you want to cancel this swap?')) e.preventDefault() }} >
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
        
          <input className="btn-link cancel-link" type="submit" value="cancel"/>
        </form>
      )
    } else if (promo['cancellable_unpaid_promo?']) {
      return (
        <form action={"/reservations/" + promo.id + "/cancel_unpaid_promo"} method='POST' onSubmit={e => { if (!confirm('Are you sure you want to cancel this booking?')) e.preventDefault() }} >
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
        
          <input className="btn-link cancel-link" type="submit" value="cancel"/>
        </form>
      )
    } else if (promo['buyer_can_request_cancel_and_refund?']) {
      return (
        <form action={"/reservations/" + promo.id + "/request_cancel_and_refund"} method='POST' onSubmit={e => { if (!confirm('Are you sure you want to request a refund?')) e.preventDefault() }} >
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
        
          <button className="btn-link cancel-link">request<br/>refund</button>
        </form>
      )
    }
  }
  
  promos() {
    if (!this.state.promos.length) {
      return (
        <tr>
          <td colSpan="5">We did not find any promos in our system for this book</td>
        </tr>
      )
    }
    
    return this.state.promos.map(promo => {
      return (
        <tr key={promo.id}>
          <td>{promo.list_name}</td>
          <td>{promo.list_size}</td>
          <td>{promo.date_in_english}</td>
          <td>{promo.inv_type}</td>
          <td>
            <a href={"/reservations/" + promo.id + "/info"} target="_blank" className={promo["pending?"] ? " pending-robin-egg-blue" : ""}>
              {promo.status}
            </a>
          </td>
          <td>
            {this.cancelAction(promo)}
          </td>
        </tr>
      )
    })
  }
  
  titleSelectorOptions() {
    let result = []
    this.state.books.forEach(book => {
      result.push({label: book.title, value: book.id})
    })
    result.push({label: 'Add Title', value: 'new'})
    return result;
  }
  
  titleSelector() {
    return (
      <Select 
        clearable={false}
        searchable={false}
        value={this.bookId()}
        onChange={this.setRedirectOrRedirect.bind(this)}
        options={this.titleSelectorOptions()} />
    )
  }
  
  setRedirectOrRedirect(selection) {
    if (selection.value == "new") {
      document.location = "/my_books/new?cal_back=launch";
      return null;
    }
    let newPath = "/my_books/" + selection.value + "/launch";
    this.setState({redirect: newPath})
  }
  
  bookId() {
    let book_id = this.props.match.params.id;
    return parseInt(book_id)
  }
  
  render() {
    
    if (this.state.redirect && this.state.redirect !== document.location.pathname) {
      console.log('redirecting')
      return <Redirect push to={this.state.redirect} />
    }
    
    let subtitles = [this.titleSelector()];
    return (
      <div id="launch-page-container">
      
        <PageTitle title="Launch Center" subtitles={subtitles} />
      
        <div id="launch-page-content">
        
          <MyBooksShow 
            bookId={this.bookId()} 
            isLaunchPage={true} isMobile={this.props.is_mobile} />
          
          <div id="booklauncher-table">
          
            <table className="table table-striped">
            
              <thead>
                <tr>
                  <th>List</th>
                  <th>List Size</th>
                  <th>Date</th>
                  <th>Type</th>
                  <th>Status</th>
                  <th>Cancel</th>
                </tr>
              </thead>
              
              <tbody>
                {this.promos()}
              </tbody>
            
            </table>
        
          </div>
          <div id="booklauncher-chart">
            <ResponsiveContainer width='100%' height={400}>
              <BarChart data={this.chartData()}>
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip cursor={{fill: 'lightgrey', fillOpacity: 0.0}} />
                <Legend verticalAlign="bottom" wrapperStyle={{ left: '50px', bottom: '-15px' }}  />
                <Bar dataKey="solo" stackId="a" fill="#606060" />
                <Bar dataKey="feature" stackId="a" fill="silver" />
                <Bar dataKey="mention" stackId="a" fill="gainsboro" />
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
                
                
          <div id="booklauncher-marketplace">
                
            <Marketplace is_mobile={this.props.is_mobile} viaLaunchPage={true} preselected_book_id={this.bookId()} />
                 
          </div>
        </div>
      </div>
    )
  }
}
