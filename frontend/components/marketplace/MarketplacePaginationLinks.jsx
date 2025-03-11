import React from 'react';

export default class MarketplacePaginationLinks extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {}
  }
  
  updatePage(page, event) {
    event.preventDefault();
    this.props.changeHandler(page);
  }
  
  render () {
    let links = [];
    for (let key in this.props.links) {
      let linkCssClass = "marketplace-pagination-link glyphicon "
      if (key == "first") {
        linkCssClass += "glyphicon-fast-backward"
      } else if (key == "last") {
        linkCssClass += "glyphicon-fast-forward"
      } else if (key == "next") {
        linkCssClass += "glyphicon-chevron-right"
      } else if (key == "prev") {
        linkCssClass += "glyphicon-chevron-left"
      }
      links.push(<a className={linkCssClass} 
                    key={key} 
                    onClick={this.updatePage.bind(this, this.props.links[key])} ></a>)
    }
    return (
      <div className="marketplace-pagination-links">
        {links}
      </div>
    )
  }
}