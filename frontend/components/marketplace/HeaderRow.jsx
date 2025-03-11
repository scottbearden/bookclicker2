import React from 'react';
import { marketplaceFields, marketplaceFieldsWithClass, marketplaceTableHeaderValues } from '../../constants/misc';
import { iOS } from '../../ext/userAgent';

export default class HeaderRow extends React.Component {
  constructor(props) {
    super(props);
    this.state = { };
  }
  
  render() {
    let tds = [];
    
    tds.push(
      <td key={"rating-actions"} className="narrow">
        <div className={"thumbs-up-filter-stuff" + (iOS() ? " ios" : "")} onClick={this.props.updateFavorites}>
          <a className="marketplace-results-order-toggle">Likes</a>
          <input type="checkbox" defaultChecked={this.props.favorites}></input> 
        </div>
      </td>
    )
    
    marketplaceFields.forEach((field, idx) => {
      
      let sortCaratClass = this.props.sort.caratCssClass(field);
      let sortCarat = <span className={sortCaratClass}/>
      tds.push(
        <td key={idx} className={marketplaceFieldsWithClass[field]}>
          <a 
            className="marketplace-results-order-toggle"
            onClick={this.props.sortHandler.bind(this, field)}>
              {marketplaceTableHeaderValues[field]}
              {sortCarat}       
          </a>
        </td>
      )
    })
    
    tds.push(<td className="med-narrow" key={"marketplace-action"}/>)
    
    return (
      <tr className="marketplace-results-header med-narrow">
        {tds}
      </tr>
    )
  }
  
}