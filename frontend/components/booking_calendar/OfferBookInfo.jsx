import React from 'react';
import { hex } from '../../ext/functions';

export default class OfferBookInfo extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      tooltipHex: hex(12)
    }
  }
  
  componentDidMount() {
    $('#' + this.state.tooltipHex).tooltip({position: 'top', html: true})
  }
  
  render() {
    let tooltipHex = hex(12);
    let items = [];

    let coverUrl = this.props.booking.book.cover_image_url;
    if (coverUrl) {
      items.push(
        <div key="cover-image-hover">
          <br/>
          <span
            id={this.state.tooltipHex}
            className="glyphicon glyphicon-book"
            style={{cursor: 'pointer', fontSize: '26px'}}
            data-placement="bottom"
            title={"<img src='" + coverUrl + "' width='120px'/>"} 
            target="_blank"></span>
        </div>
      )
    }

    if (this.props.booking.book.title) {
      items.push(<div key="title">{this.props.booking.book.title}</div>)
    }
    if (this.props.booking.book.author) {
      items.push(<div key="author"><span>Author:</span> <i>{this.props.booking.book.author}</i></div>)
    }

    this.props.booking.book.book_links.forEach((bookLink) => {
      items.push(<div key={"book-link-" + bookLink.id}><a href={bookLink.link_url} target="_blank"><i>{bookLink.website_name || bookLink.link_url}</i></a></div>)
    })

    items.push(
      <div key="details">
        <br/>
        <a href={"/reservations/" + this.props.booking.id + "/info"} target="_blank">Booking Details</a>
      </div>
    )

    items.push(<hr/>)
       
    return (
      <div className="booking-form-title-stats">
       {items}
      </div>
    )
  }
    
}
