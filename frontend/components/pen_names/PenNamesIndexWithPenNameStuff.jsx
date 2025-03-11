import React from 'react';
import { Link } from 'react-router-dom';
import PenNamesApi from '../../api/PenNamesApi';
import MyBooksIndex from '../my_books/MyBooksIndex';
import PenNameForm from './PenNameForm';
import withPenNameStuff from './withPenNameStuff';
import PageTitle from '../PageTitle';

class PenNamesIndex extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      newPenNameFormOpen: false
    }
  }
  
  penNamePills() {
    let result = [];
    this.props.penNames.forEach((pen_name, idx) => {
      result.push(this.penNamePill(pen_name))
    })
    result.push(<div id='new' key="new-anchor-tag"></div>)
    result.push(
      <div className={"pen-name-pill-wrapper new" + (this.state.newPenNameFormOpen ? ' open' : '')} onClick={this.openNewPenNameForm.bind(this)} key={"new"}>
        
        <div className={"pen-name-pill-content"}>
          <div className="pen-name-header">Add Pen Name / Promo Service</div>
        </div>
        
        {this.state.newPenNameFormOpen ? 
          <PenNameForm 
            setFlash={this.props.setFlash}
            closeNewPenNameForm={this.closeNewPenNameForm.bind(this)}
            reloadPenNames={this.props.reloadPenNames}/> : null}  
        
      </div>
    )
    
    return result;
  }
  
  penNamePill(pen_name) {
    return (
      <div className="pen-name-pill-wrapper" key={pen_name.id}>
        
        <div className="pen-name-pill-content">
              
          <div className="pen-name-pill-item verified">
            <div className={"pen-name-pill-item-content left"}>
              {this.editToggleLink(pen_name)}
            </div>
          </div>
        
          <div className="pen-name-pill-item">
            <div className="pen-name-pill-item-content">
              {pen_name.author_name}
            </div>
          </div>
        
          <div className="pen-name-pill-item author-image">
            <div className="pen-name-pill-item-content">
              {this.props.verifiedStatusContent(pen_name)}
            </div>
          </div>
        </div>
        
        {pen_name.formOpen ? 
          <PenNameForm 
            penName={pen_name}
            setFlash={this.props.setFlash}
            closeNewPenNameForm={this.closeNewPenNameForm.bind(this)}
            reloadPenNames={this.props.reloadPenNames.bind(this)}/> : null}
          
        <div className="pen-name-pill-content">
          <div className="pen-name-pill-books">
            <MyBooksIndex 
              books={pen_name.books.filter(book => {
                return book.user_id == this.props.currentMemberUserId
              })} 
              disallowBooks={!!pen_name.promo_service_only}
              setFlash={this.props.setFlash}
              penNameId={pen_name.id}/>
          </div>
        </div>
          
      </div>
    )
  }
  
  openNewPenNameForm() {
    if (!this.state.newPenNameFormOpen) {
      this.setState({newPenNameFormOpen: true})
    }
  }
  
  closeNewPenNameForm() {
    this.setState({newPenNameFormOpen: false})
  }
  
  toggleEditPenNameForm(penNameId) {
    const penNames = this.props.penNames.map(pen_name => {
      if (pen_name.id == penNameId) {
        pen_name.formOpen = !pen_name.formOpen;
      }
      return pen_name;
    })
    this.props.setWrapperState({penNames})
  }
  
  editToggleLink(pen_name) {
    let text = ""
    if (this.props.currentMemberUserId !== pen_name.user_id) {
      return null;
    } else if (pen_name.formOpen) {
      text = "Cancel"
    } else {
      text =  "Edit " + (pen_name.promo_service_only ? "Promo Service" : "Pen Name")
    }
    return (
      <a onClick={this.toggleEditPenNameForm.bind(this, pen_name.id)}>
        {text}
      </a>
    )
  }
  
  subtitles() {
    let result = [<b>Manage Pen Names</b>];
    if (this.props.penNameGroups.length) {
      result.push(<Link to={'/pen_names/sharing'}>Manage Pen Name Sharing</Link>)
    }
    return result
  }
  
  render() {
    return (
      <div id="pen-names-index">
        <PageTitle title={'Pen Names'} subtitles={this.subtitles()} />
        <div id="pen-names-pills">
          {this.penNamePills()}
        </div>
      </div>
    )
  }
  
}

const PenNamesIndexWithPenNameStuff = withPenNameStuff(PenNamesIndex);
export default PenNamesIndexWithPenNameStuff;