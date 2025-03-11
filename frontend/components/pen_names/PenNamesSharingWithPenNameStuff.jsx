import React from 'react';
import { Link } from 'react-router-dom';
import PageTitle from '../PageTitle';
import withPenNameStuff from './withPenNameStuff';

class PenNamesSharing extends React.Component {
  
  render() {
    
    
    return (
      <div id="pen-names-index">
        <PageTitle title={'Pen Name Sharing'} subtitles={[
          <Link to={"/pen_names"}>Manage Pen Names</Link>,
          <b>Manage Pen Name Sharing</b>
        ]} />
        
        <div id="pen-names-pills">
          {this.penNameGroups()}
        </div>
        
        {this.penNameRequests()}
        
        {this.noteIfPageEmpty()}
      </div>
    )
  }
  
  penNameRequests() {
  }
  
  subtitles() {
    let result = [
      <Link to={"/pen_names"}>Manage Your Pen Names</Link>,
      <b>Manage Pen Name Sharing</b>
    ];
    return result;
  }
  
  penNameGroups() {
    return this.props.penNameGroups.map(group => {
      return this.penNameGroup(group)
    })
  }
  
  penNameGroup(pen_name_group) {
    return (
      <div className="pen-name-pill-wrapper" key={pen_name_group.id}>
      
        <div className="pen-name-pill-content">
            
          <div className="pen-name-pill-item">
            <div className={"pen-name-pill-item-content"}>
            </div>
          </div>
      
          <div className="pen-name-pill-item">
            <div className="pen-name-pill-item-content">
              {pen_name_group.author_name}
            </div>
          </div>
      
          <div className="pen-name-pill-item author-image">
            <div className="pen-name-pill-item-content">
            </div>
          </div>
          
        </div>
      
        <div className="pen-name-pill-content">
          <div className="pen-name-pill-users">
            {this.penNameGroupUsers(pen_name_group)}
          </div>
        </div>
        
      </div>
    )
  }
  
  penNameGroupUsers(pen_name_group) {
    return pen_name_group.users.map(user => {
      return this.userRow(user)
    })

  }
  
  userRow(user) {
    return (
      <div className="pen-name-pill-user" key={user.id}>
      
        <div className="pen-name-user-name-email">
          <div className="phone">{user.full_name}</div>
          <div className="not-phone" dangerouslySetInnerHTML={{__html: user.name_fallback_email}}></div>
        </div>
        
        <div className="pen-name-user-remove">
          <button className="bclick-button bclick-solid-black-button">Remove</button>
        </div>
      
      </div>
    )
  }
  
  
  noteIfPageEmpty() {
    if (!this.props.penNameGroups.length) {
      return <h3 style={{textAlign: 'center'}}>You do not manage any pen name groups</h3>
    }
  }
  
}

const PenNamesSharingWithPenNameStuff = withPenNameStuff(PenNamesSharing);
export default PenNamesSharingWithPenNameStuff;