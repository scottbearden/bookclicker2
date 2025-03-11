import React from 'react';
import { Link } from 'react-router-dom';
import MyListsApi from '../../api/MyListsApi';
import MyListsRow from './MyListsRow';
import PageTitle from '../PageTitle';

const tableHeaderValues = {
  "name": "Name",
  "adopted_pen_name": "Public Pen Name",
  "active_member_count_delimited": "Size",
  "Platform": "Platform",
  "open_rate": "Open Rate",
  "click_rate": "Click Rate",
  "solo_price": "Solo",
  "feature_price": "Feature",
  "mention_price": "Mention"
}

export default class MyListsIndex extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      lists: [],
      loading: true
     };
  }
  
  componentDidMount() {
    MyListsApi.getMyLists("maybe").then(res => {
      this.setState({ lists: res.lists, loading: false, penNames: res.pen_names })
    }, res => {
      this.setState({loading: 'error'})
    }) 
  }
  
  render() {
    
    let headers = <MyListsRow attributes={tableHeaderValues} penNames={this.state.penNames} isHead={true}></MyListsRow>
    let lists = this.state.lists.map((listAttrs, idx) => (
      <MyListsRow attributes={listAttrs} key={idx}></MyListsRow>
    ));
    if (!lists.length) {
      if (this.state.loading === 'error') {
        lists.push(<tr key="none"><td colSpan="100%">There was an error loading your lists</td></tr>);
      } else if (this.state.loading) {
        lists.push(<tr key="none"><td colSpan="100%">Your lists are loading</td></tr>);
      } else {
        lists.push(<tr key="none"><td colSpan="100%">You have no lists for sale. <a href="/my_lists/selections">Please select active lists</a></td></tr>);
      } 
    }
    
    return (
      <div id="my-lists-index">
        <PageTitle title='My Mailing Lists' subtitles={['Your active lists']}/>
        <div className="my-lists-index-link-to-selections">
          <Link
            to={"/my_lists/selections"}
            className="bclick-button bclick-hollow-mailchimp-gray-button bclick-large-button">
            <span>View All Mailing Lists</span>
          </Link>
        </div>
        <table className="table table-striped">
          <thead className="thead">
            {headers}
          </thead>
          <tbody>
            {lists}
          </tbody>
        </table>
      </div>
    )
  }
  
}