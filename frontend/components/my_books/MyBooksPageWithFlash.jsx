import React from 'react';
import { BrowserRouter, Match, Route, Link } from 'react-router-dom';

import PageTitle from '../PageTitle';
import MyBooksIndex from './MyBooksIndex';
import MyBooksShow from './MyBooksShow';
import withFlash from '../shared/withFlash';

class MyBooksPage extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  render() {
    let title = 'Book Info';
    let subtitles = [];
    
    return (
      <div id="my-books-page">
        {this.props.flashMessage()}
        <PageTitle title={title} subtitles={subtitles} />
        <div id="my-books-page-content">
          <BrowserRouter>
            <div>
              
              <Route path="/my_books/:id(\d+)" render={(props) => (
                <MyBooksShow 
                  isNew={false} 
                  isMobile={this.props.is_mobile}
                  book={this.props.book}
                  setFlash={this.props.setFlash} 
                  bookId={props.match.params.id} />
              )}>
              </Route>
              
              <Route path="/my_books/new" render={(props) => (
                <MyBooksShow 
                  isNew={true} 
                  isMobile={this.props.is_mobile}
                  setFlash={this.props.setFlash} />
              )}>
              </Route>

            </div>
          </BrowserRouter>
        </div>
      </div>
    )
  }
  
}

const MyBooksPageWithFlash = withFlash(MyBooksPage);

export default MyBooksPageWithFlash


