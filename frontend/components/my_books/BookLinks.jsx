import React from 'react';

export default class BookLinks extends React.Component {
  
  constructor(props) {
    super(props);
  }
  
  bookLinkInput(bookLinkAttrs, idx) {
    return (
      <div className="my-books-link" key={idx} style={{"display": (bookLinkAttrs._destroy ? "none" : "block")}}>
        <input 
          type="hidden" 
          name="book[book_links_attributes][][id]"
          value={bookLinkAttrs.id || ''} />
        <input 
          type="hidden" 
          name="book[book_links_attributes][][_destroy]"
          value={bookLinkAttrs._destroy || false} />
          
        <div className="my-books-link-url-input">
          <input 
            type="text" 
            className="my-books-link-url-input-input"
            placeholder={bookLinkAttrs.placeholder || "URL"}
            name="book[book_links_attributes][][link_url]"
            value={bookLinkAttrs.link_url || ''}
            onBlur={this.blurBookLink.bind(this)}
            onChange={this.updateBookLink.bind(this, 'edit', bookLinkAttrs.id, idx)}/>
        </div>
        <div className="my-books-link-remove">
          <span 
            className="glyphicon glyphicon-remove"
            onClick={this.updateBookLink.bind(this, 'remove', bookLinkAttrs.id, idx)}>
          </span>
        </div>
      </div>
    )
  }
  
  updateNewBookLink(event, action, elemIdx) {
    let bookLinks = []
    if (action === "edit") {
      bookLinks = this.props.bookLinks.map((book_link, idx) => {
        return (!book_link.id && elemIdx === idx) ? {link_url: event.target.value} : book_link;
      })
    } else if (action === "remove") {
      bookLinks = this.props.bookLinks.filter((book_link, idx) => {
        return (!book_link.id && elemIdx === idx) ? false : true;
      })
    }
    this.props.propogateBookLinks(bookLinks)
  }
  
  updateOldBookLink(event, action, bookLinkId) {
    let bookLinks = this.props.bookLinks.map((bookLink) => {
      if (bookLink.id == bookLinkId) {
        if (action == "edit") {
          bookLink.link_url = event.target.value
        } else if (action == "remove") {
          bookLink._destroy = true;
        }
      }
      return bookLink;
    })
    this.props.propogateBookLinks(bookLinks)
  }
  
  addNewBookLink(event) {
    event.preventDefault()
    let bookLinks = this.props.bookLinks.concat({});
    this.props.propogateBookLinks(bookLinks, 'cancel')  
  }
  
  updateBookLink(action, id, elemIdx, event) {
    if (id) {
      this.updateOldBookLink(event, action, id);
    } else {
      this.updateNewBookLink(event, action, elemIdx);
    }
  }
  
  blurBookLink(event) {
    let url = event.target && event.target.value.toLowerCase();
    if (url.match(/\/dp\//)) {
      this.props.populateWithApi(url, 'amazon_products')
    } else if (url.match(/play\.google\.com/)) {
      this.props.populateWithApi(event.target.value, 'google_books')
    } else {
      this.props.triggerSave()
    }
  }

  hasExhaustedBooklinks() {
    return this.props.bookLinks.length >= 6;
  }

  addBookLinkButton() {
    return (
      <div className="my-books-add-link">
        <button
          onClick={this.addNewBookLink.bind(this)}
          className="bclick-button bclick-hollow-robin-egg-blue-button">
          Add Link
        </button>
      </div>
    )
  }
  
  render() {
    let bookLinks = this.props.bookLinks.map((bookLinkAttrs,idx) => {
      return this.bookLinkInput(bookLinkAttrs, idx);
    }) 
    
    return (
      <div className="my-books-links">
        {bookLinks}
        {this.hasExhaustedBooklinks() ? null : this.addBookLinkButton()}
      </div>
    )
  }
  
}
