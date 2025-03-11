
import React from 'react';
import MyBooksApi from '../../api/MyBooksApi';
import Select from 'react-select';

export default class AddNewBookForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      newBookTitle: null,
      penNameId: null,
      savingNewBook: false
    }
  }
  
  changeNewBookTitle(event) {
    this.setState({newBookTitle: event ? event.target.value : null})
  }
  
  changeNewBookPenNameId(select) {
    let penNameId = select ? select.value : null;
    this.setState({penNameId})
  }
  
  penNameOptions() {
    return this.props.penNames.map((pen_name, idx) => {
      return { value: pen_name.id, label: pen_name.author_name }
    })
  }
  
  selectedPenNameId() {
    return this.state.penNameId || (this.props.penNames.length && this.props.penNames[0].id)
  }
  
  render() {
    if (this.props.showNewBookForm) {
      return (
        <div className="book-add-container">
          <div className="book-add-form">
          
            <div className="book-add-input book-name">
              <input type="text" className="form-control" 
                placeholder="New Book Title" 
                onChange={this.changeNewBookTitle.bind(this)}
                value={this.state.newBookTitle || ''}/>
            </div>
            <div className="book-add-input space not-phone">&nbsp;</div>
            <div className="book-add-input pen-name">
              <Select
                name="pen_name_id"
                required
                clearable={false}
                searchable={false}
                onChange={this.changeNewBookPenNameId.bind(this)}
                value={this.selectedPenNameId() || ''}
                options={this.penNameOptions()} />
            </div>
            <div className="book-add-input space">&nbsp;</div>
            <div className="book-add-input submit">
              <a disabled={this.saveNewBookDisabled()}
                onClick={this.saveNewBook.bind(this)}
                className="bclick-button bclick-hollow-black-button">{this.state.savingNewBook ? "Saving" : "Save"}</a>
            </div>
          </div>
        </div>
      )
    } else {
      return null;
    }
  }
  
  saveNewBookDisabled() {
    return !this.state.newBookTitle || this.state.savingNewBook
  }
  
  saveNewBook(event) {
    event.preventDefault();
    if (this.saveNewBookDisabled()) {
      return null;
    }
    
    this.setState({savingNewBook: true}, function() {
      MyBooksApi.create(this.state.newBookTitle, this.selectedPenNameId()).then(res => {
        this.setState({savingNewBook: false, newBookTitle: null}, function() {
          this.props.setBookingFormState({books: res.books, showNewBookForm: false, bookId: res.book.id})
        })
      }, errRes => {
        this.setState({savingNewBook: false});
        let errMessage = 'There was an error saving your book.';
        if (errRes && errRes.responseJSON) {
          errMessage += '  ' + errRes.responseJSON.message
        }
        alert(errMessage)
      })
    })
    
  }
  
}