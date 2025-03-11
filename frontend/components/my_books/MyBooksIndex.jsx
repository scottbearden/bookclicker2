import React from 'react';
import MyBooksApi from '../../api/MyBooksApi';
import BookRow from './BookRow';

export default class MyBooksIndex extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { books: this.props.books };
  }
  
  deleteBook(bookId, bookTitle) {
    var that = this;
    if (window.confirm("Are you sure you want to delete '" + bookTitle + "'?")) {
      MyBooksApi.deleteMyBook(bookId).then(res => {
        that.setState({ books: res.books })
      }, error => {
        if (error.responseJSON) {
          this.props.setFlash(error.responseJSON.message, 'danger')
        }
      })
    }
  }
  
  newBookRow() {
    return (
      <tr className="book-row-new-book">
        <td key="new" colSpan="7" className="new-book-td" >
          <a 
            role="button"
            className="bclick-button bclick-solid-notification-button-button"
            style={{borderRadius: '5px'}}
            href={"/my_books/new?pen_name_id=" + this.props.penNameId}>
            <span className="not-phone">Add New Book</span>
            <span className="phone">Add Book</span>
          </a>
        </td>
      </tr>
    )
  }
  
  tBody(books) {
    if (!this.props.disallowBooks) {
      return (
        <tbody>
          {books}
          {this.newBookRow()}
        </tbody>
      )
    } else {
      return <tbody></tbody>;
    }
  }
  
  tHead() {
    if (true) {
      return (
        <thead>
          <tr className="book-row-row">
            <td colSpan="7">&nbsp;</td>
          </tr>
        </thead>
      )
    }
  }
  
  render() {
    
    let books = this.state.books.map((bookAttrs, idx) => (
      <BookRow attributes={bookAttrs} key={bookAttrs.id} delete={this.deleteBook.bind(this)}></BookRow>
    ));
    
    return (
      <div className="my-books-index">
        <table className="table table-striped">
          {this.tHead()}
          {this.tBody(books)}
        </table>
      </div>
    )
  }
  
}
