import React from 'react';
import { grabCsrfToken } from '../../ext/functions';

export default class MyListsSelectWarning extends React.Component {

  constructor(props) {
    super(props);
    this.state = {}
  }


  listsStatusesHiddenInputs() {
    return this.props.lists.map((list,idx) => {
      return (
        <div key={idx} className="pair-of-nested-params">
          <input 
            type="hidden" 
            name={"lists_attributes[][id]"} 
            value={list.id} />
          <input 
            type="hidden" 
            name={"lists_attributes[][status]"} 
            value={list.status} />
          <input 
            type="hidden" 
            name={"lists_attributes[][pen_name_id]"} 
            value={list.pen_name_id || ''} />
        </div>
      )
    })
  }

  listOrLists() {
    return this.props.lists.filter(list => (list.status == 'active')).length === 1 ? 'list' : 'lists'
  }
  
  render() {
    return (
      <div id="pen-name-form-wrapper">
        <form action="/my_lists/selections" method="POST">
          <input type="hidden" name="_method" value="PUT"/>
          <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
          {this.listsStatusesHiddenInputs()}

          <div className="pen-name-form-content">
            <div className="pen-name-submit-wrapper">
              <input type="submit" value="Save" className="bclick-button bclick-solid-robin-egg-blue-button" />
            </div>
          </div>
        </form>
        <div id="pen-name-form-disclaimer">
          <span>Once you confirm, these details will be viewable on the marketplace</span>
        </div>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
      </div>
    )

  }
  


}
