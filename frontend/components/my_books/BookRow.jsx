import React from 'react';
import { Link } from 'react-router-dom';

export default class BookRow extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      attributes: props.attributes
    };
  }
  
  render() {
    let tds = ["title", "launch_date_in_english", "cover_image_url", "amazon_link_url", "google_play_link_url"].map((attr, id) => {
      let attrVal = this.state.attributes[attr];
      
      let tdCss = attr.match(/\_url$/) ? 'not-phone my-books-row-td centerify' : 'my-books-row-td'
      if (attr == 'title') {
        tdCss += ' td-title'
      }
      if (attr == 'launch_date_in_english') {
        tdCss += ' centerify'
      }
      
      let inner = "";
      
      if (attr == "cover_image_url" && attrVal) {
        inner = <a className={"glyphicon glyphicon-camera"} href={attrVal} target="_blank"></a>
      } else if (attr == "amazon_link_url" && attrVal) {
        inner = <a href={attrVal} target="_blank">amazon</a>
      } else if (attr == "google_play_link_url" && attrVal) {
        inner = <a href={attrVal} target="_blank">google</a>
      } else {
        inner = <div target="_blank">{attrVal || "_"}</div>
      }
      
      return <td key={id} className={tdCss}>{inner}</td> 
      
    })

    return (
      <tr className="book-row-row">
        <td key="edit" className="edit-book my-books-row-td centerify">
          <a 
            className={"glyphicon glyphicon-signal"}
            href={"/my_books/" + this.props.attributes.id + "/launch"}>
          </a>
          <a 
            className={"glyphicon glyphicon-pencil"}
            href={"/my_books/" + this.props.attributes.id}>
          </a>
        </td>
        
        {tds}
        
        <td key="deleto" className="delete-book my-books-row-td">
          <a 
            className={"glyphicon glyphicon-remove" + (this.props.attributes['can_delete?'] ? " red" : " grey")}
            onClick={this.props.delete.bind(this, this.props.attributes.id, this.props.attributes.title)}>
          </a>
        </td>
      </tr>
    )
  }
  
}
