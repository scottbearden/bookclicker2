import React from 'react';
import { iOS } from '../../ext/userAgent';


export default class PriceInput extends React.Component {
  
  
  constructor(props) {
    super(props);
    this.state = {};
  }
  
  captureZeroPrice() {
    if (this.props.price === 0) {
      return 0
    } else {
      return this.props.price || '';
    }
  }
  
  render() {
    let title = this.props.priceType[0].toUpperCase() + this.props.priceType.substring(1);
    return (
      <div className="my-lists-show-price-container">
        <div className="my-lists-show-price-content">
          <div className="my-lists-show-price-title">
            {title}
          </div>
        
          <div className="my-lists-show-price-input">
            <div className="price-dollar-sign">$</div>
            <input type="number"
                   name={this.props.priceType + "_price"} 
                   value={this.captureZeroPrice()} 
                   onChange={this.props.changeHandler}/>
          </div>
      
          <div className="my-lists-show-price-clear">
            <a className="my-lists-show-price-clear-button bclick-button bclick-xsmall-button bclick-solid-grey-button" onClick={this.props.clearHandler}>
              clear
            </a>
          </div>
          
          <div className={"my-lists-show-price-clear" + (iOS() ? " ios" : "")}>
            
            <input type="checkbox" checked={this.props.is_swap_only ? true : false} onClick={this.props.toggleSwapOnly} />
            <a className="my-lists-show-price-clear-button bclick-button bclick-xsmall-button bclick-hollow-black-button" onClick={this.props.toggleSwapOnly}>
              Swap Only
            </a>
          </div>
        </div>
      </div>
    )
  }
  
}