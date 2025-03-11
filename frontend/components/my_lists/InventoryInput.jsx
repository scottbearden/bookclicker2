import React from 'react';
import { iOS } from '../../ext/userAgent';
import NumericInput from 'react-numeric-input';


export default class InventoryInput extends React.Component {
  
  
  constructor(props) {
    super(props);
    this.state = {};
  }

  isTheoreticallyNotAllowed(inventory, day) {
    if (inventory.inv_type == 'feature' || inventory.inv_type == 'mention') {
      return !(inventory[day] > 0) && (this.props.inventories.solo[day] > 0);
    } else if (inventory.inv_type == 'solo') {
      return !(inventory[day] > 0) && (this.props.inventories.feature[day] > 0 || this.props.inventories.mention[day] > 0);
    }
  }
  
  buildCheckboxRow(inventory, idx) {

    let tds = ["sunday","monday", "tuesday", "wednesday", "thursday", "friday", "saturday"].map((day) => {
      return (
        <td 
         key={inventory.inv_type + "-" + day} 
         data-inv_type={inventory.inv_type}
         className={"inventory-day-box" + (iOS() ? " ios" : "")}>
          <input
            type="checkbox"
            value="1"
            data-inv_type={inventory.inv_type}
            data-day={day}
            checked={inventory[day]}
            onChange={this.props.soloFeatureChangeHandler.bind(this, inventory.inv_type, day)}
            name={"inventories[" + inventory.inv_type + "][" + day + "]"}/>
        </td>
      )
    });
    
    tds.unshift(<td key={inventory.inv_type + "-x"} className="inventory-checkboxes-inv-type">{inventory.inv_type}</td>)

    return (
      <tr key={idx} className="inventory-checkboxes-row">
        {tds}
      </tr>
    )
  }

  buildNumberRow(inventory, idx) {
    let tds = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"].map((day) => {
          return (<td 
            key={inventory.inv_type + "-" + day} 
            data-inv_type={inventory.inv_type}
            className={"inventory-day-box" + (iOS() ? " ios" : "")}>
            
            <NumericInput
              className="mention-input"
              data-inv_type="mention"
              type="number"
              mobile={false}
              min={0}
              max={9}
              step={1}
              value={inventory[day]}
              style={{ input: { textAlign: (this.props.isMobile ? "left" : "center")} }}
              onChange={this.props.mentionsChangeHandler.bind(this, inventory.inv_type, day)}
              name={"inventories[" + inventory.inv_type + "][" + day + "]"}/>
          </td>)
    });

    tds.unshift(<td key={inventory.inv_type + "-x"} className="inventory-checkboxes-inv-type">{inventory.inv_type}s</td>)

    return (
      <tr key={idx} className="inventory-checkboxes-row">
        {tds}
      </tr>
    )
  }
  
  render() {

    let checkboxRows = []
    if (this.props.inventories.solo) {
      checkboxRows.push(this.buildCheckboxRow(this.props.inventories.solo, 0));
    }

    if (this.props.inventories.feature) {
      checkboxRows.push(this.buildCheckboxRow(this.props.inventories.feature, 1));
    }

    if (this.props.inventories.mention) {
      checkboxRows.push(this.buildNumberRow(this.props.inventories.mention, 2));
    }

    return (
      <div className="my-lists-show-inventory-container">
        <div className="my-lists-show-inventory-content">
          <table className="table table-striped">
            <thead>
              <tr>
                <td className="inventory-day-header"></td>
                <td className="inventory-day-header">
                  <span className="not-phone">Sunday</span>
                  <span className="phone">Su</span>
                </td>
                
                <td className="inventory-day-header">
                  <span className="not-phone">Monday</span>
                  <span className="phone">Mo</span>
                </td>
                
                <td className="inventory-day-header">
                  <span className="not-phone">Tuesday</span>
                  <span className="phone">Tu</span>
                </td>
                
                <td className="inventory-day-header">
                  <span className="not-phone">Wednesday</span>
                  <span className="phone">We</span>
                </td>
                
                <td className="inventory-day-header">
                  <span className="not-phone">Thursday</span>
                  <span className="phone">Th</span>
                </td>
                
                <td className="inventory-day-header">
                  <span className="not-phone">Friday</span>
                  <span className="phone">Fr</span>
                </td>
                
                <td className="inventory-day-header">
                  <span className="not-phone">Saturday</span>
                  <span className="phone">Sa</span>
                </td>
                
              </tr>
            </thead>
            <tbody>
              {checkboxRows}
            </tbody>
          </table>
        </div>
      </div>
    )
  }
  
}