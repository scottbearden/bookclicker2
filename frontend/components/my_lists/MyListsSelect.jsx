import React from 'react';
import { Link } from 'react-router-dom';
import { grabCsrfToken } from '../../ext/functions';
import MyListsApi from '../../api/MyListsApi';
import MyListsRow from './MyListsRow';
import MyListsSelectWarning from './MyListsSelectWarning';
import ReactDOM from 'react-dom';
import PageTitle from '../PageTitle';

const tableHeaderValues = {
  "name": "Name",
  "active_member_count_delimited": "Size",
  "pen_name_id": "Pen Name",
  "adopted_pen_name": "Public Pen Name",
  "Platform": "Platform",
  "open_rate": "Open Rate",
  "click_rate": "Click Rate",
  "solo_price": "Solo",
  "feature_price": "Feature",
  "mention_price": "Mention"
}

export default class MyListsSelect extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      lists: [],
      loading: true,
      penNames: []
    };
  }
  
  componentDidMount() {
    MyListsApi.getMyLists("maybe", true).then(res => {
      this.setState({ lists: res.lists, penNames: res.pen_names, loading: false })
    })    
  }

  showPenNameModal(event) {
    event.preventDefault();
    let $reusableModal = $('#reusableModal')
    $reusableModal.find('.modal-header').html("<h3>My Lists</h3>")
    $reusableModal.find('.modal-body').addClass('minimal-padding').html("<div id='MyListsSelectWarning'></div>");
    let lsw = document.getElementById('MyListsSelectWarning');
    ReactDOM.render( 
      <MyListsSelectWarning 
        lists={this.state.lists} />
      , lsw)
    $reusableModal.modal();
  }
  
  setListField(listId, field, value, callback) {
    const lists = this.state.lists.map(list => {
      if (list.id == listId) {
        list[field] = value
      }
      return list
    })
    this.setState({lists}, function() {
      callback && callback()
    })
  }
  
  noListsFound() {
    return !this.state.lists.length
  }
  
  render() {
    
    let headers = <MyListsRow attributes={tableHeaderValues} isHead={true} isSelecting={true}></MyListsRow>
    let lists = this.state.lists.map((listAttrs, idx) => (
      <MyListsRow 
        attributes={listAttrs} 
        isSelecting={true} 
        setParentState={this.setState.bind(this)}
        penNames={this.state.penNames}
        key={listAttrs.id}
        setListField={this.setListField.bind(this)}></MyListsRow>
    ));

    if (!lists.length) {
      if (this.state.loading === 'error') {
        lists.push(<tr key="none"><td colSpan="100%">There was an error loading your lists</td></tr>);
      } else if (this.state.loading) {
        lists.push(<tr key="none"><td colSpan="100%">Your lists are loading</td></tr>);
      } else {
        lists.push(<tr key="none"><td colSpan="100%">You have no lists available. <a href='/integrations'>Set up an integration</a></td></tr>);
      } 
    }
    
    return (
      <div id="my-lists-index">
        <PageTitle title='My Mailing Lists' subtitles={['Select the lists you would like to activate']}/>
        <div className="my-lists-index-link-to-selections">
          <Link
            to={"/my_lists"}
            className="bclick-button bclick-hollow-mailchimp-gray-button bclick-large-button">
            <span>Active Lists</span>
          </Link>
        </div>
        <form action="/my_lists/selections" method="POST" onSubmit={this.showPenNameModal.bind(this)}>
          <input type="hidden" name="_method" value="PUT"/>
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
          <table className="table table-striped">
            <thead className="thead">
              {headers}
            </thead>
            <tbody>
              {lists}
            </tbody>
          </table>
          <div className="my-lists-select-submit" style={{display: !this.state.lists.length ? "none" : "block"}}>
            <input type="submit" value="Save" className="bclick-button bclick-solid-robin-egg-blue-button"/>
          </div>
        </form>
      </div>
    )
  }
  
  
}
