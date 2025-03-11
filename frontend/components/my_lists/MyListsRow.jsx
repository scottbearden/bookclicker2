import React from 'react';
import { Link } from 'react-router-dom';
import { iOS } from '../../ext/userAgent';
import MyListsApi from '../../api/MyListsApi';
import { decimalToPercent } from '../../ext/functions';
import Select from 'react-select';

const fieldsOrdered = {
  select: [
    "name",
    "active_member_count_delimited",
    "Platform",
    "open_rate",
    "click_rate",
    "adopted_pen_name",
    "pen_name_id"
  ],
  manage: [
    "adopted_pen_name",
    "active_member_count_delimited",
    "Platform",
    "open_rate",
    "click_rate",
    "solo_price",
    "feature_price",
    "mention_price"
  ]
}

const fieldsMobile = {
  select: [
    "name",
    "pen_name_id"
  ],
  manage: [
    "adopted_pen_name",
    "pen_name_id"
  ]
}

const fieldsTablet = {
  select: [
    "name",
    "active_member_count_delimited",
    "adopted_pen_name",
    "pen_name_id"
  ],
  manage: [
    "adopted_pen_name",
    "active_member_count_delimited",
    "solo_price",
    "feature_price",
    "mention_price"  
  ]
}

export default class MyListsRow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      saving: false,
      saveIndicator: null
    };
  }
  
  penNameOptions() {
    if (this.props.penNames === undefined) return [];
    
    let options = [];
    this.props.penNames.forEach(pen_name => {
      options.push({label: pen_name.author_name, value: pen_name.id})
    })
    options.push({label: "Add New", value: "new"})
    return options;
  }
  
  updatePenName(selection) {
    let penNameId = selection ? selection.value : null;
    if (penNameId === "new") {
      if (confirm('You are about to be redirected to another page to create a Pen Name.  Is this what you want?')) {
        document.location = "/pen_names#new"  
      }
    } else {
      this.props.setListField(this.props.attributes.id, 'pen_name_id', penNameId, this.save.bind(this))
    }
  }
  
  updateStatus(event) {
    let listStatus = event.target.checked ? "active" : "inactive";
    this.props.setListField(this.props.attributes.id, 'status', listStatus, this.save.bind(this))
  }
  
  save(penNameId) {
    if (!this.state.saving) {
      this.setState({saving: true}, function() {
        MyListsApi.updateMyList(this.props.attributes.id, this.dataToSave()).then(res => {
          this.props.setParentState({lists: res.lists})
          this.setState({saving: false}, this.setSaveIndicator.bind(this, 'success', 800))
        }, res => {
          this.setState({saving: false}, this.setSaveIndicator.bind(this, 'error', 800))
          if (res.responseJSON && res.responseJSON.message) {
            alert(res.responseJSON.message)
          }
        })
      })
    }
  }
  
  dataToSave() {
    return {
      pen_name_id: this.props.attributes.pen_name_id,
      status: this.props.attributes.status
    }
  }
  
  setSaveIndicator(saveIndicator, durationMs) {
    var that = this;
    this.setState({saveIndicator}, function() {
      setTimeout(function() {
        that.setState({saveIndicator: null})
      }, durationMs)
    })
  }
  
  saveIndicatorClass() {
    if (this.state.saveIndicator) {
      return this.state.saveIndicator;
    } else if (this.props.attributes.status == 'active' && !this.props.attributes.pen_name_id) {
      return "error";
    }
  }

  tdCssClass(attr) {
    let result = "";
    if (attr.match(/_rate|_price|member_count/)) {
      result += "my-list-row-narrow "
    } else if (attr.match(/latform/)) {
      result += "my-list-row-platform "
    } else if (attr.match(/^name$/)) {
      result += "my-list-row-squinch ";
    } 
    if (fieldsTablet[this.props.isSelecting ? 'select' : 'manage'].indexOf(attr) < 0) {
      result += "wide-desktop";
    } else if (fieldsMobile[this.props.isSelecting ? 'select' : 'manage'].indexOf(attr) < 0) {
      result += "not-phone";
    } else if (attr == 'name' || attr == 'adopted_pen_name') {
      result += "list-name";
    }
    return result
  }
  
  attrFormatted(attr) {
    let val = this.props.attributes[attr];
    if (this.props.isHead) {
      return val;
    } else if (!val && val !== 0) {
      return "_"
    } else if (attr == 'open_rate' || attr == 'click_rate') {
      return decimalToPercent(val);
    } else if (attr.match(/_price/)) {
      return '$' + val;  
    } else {
      return val;
    }
  }
  
  render() {
    let fields = fieldsOrdered[this.props.isSelecting ? 'select' : 'manage']
    let tds = fields.map((attr, id) => {
      if (this.props.isSelecting && !this.props.isHead && attr == 'pen_name_id') {
        return (
          <td key={id} className={this.tdCssClass(attr)}>
            <Select 
              className={"list-select-pen-name-input " + (this.saveIndicatorClass()) }
              type="text" 
              value={this.props.attributes.pen_name_id || ''}
              searchable={false}
              placeholder="Pen Name..."
              options={this.penNameOptions()}
              onChange={this.updatePenName.bind(this)}/>
          </td>
        )
      } else {
        return (
          <td key={id} 
            className={this.tdCssClass(attr)}>
            {this.attrFormatted(attr)}
          </td>
        )
      }
    })
    if (this.props.isSelecting) {
      if (this.props.isHead) {
        tds.push(<td key="select" className="my-lists-select-checkbox-container">For Sale?</td>)
      } else {
        tds.push(
          <td key="select" className={"my-lists-select-checkbox-container" + (iOS() ? " ios" : "")}>
            <input 
              type="checkbox" 
              value="active"
              checked={this.props.attributes.status == "active"}
              onChange={this.updateStatus.bind(this)}/>
          </td>
        )
      }
    }
    
    let setUpInventoryButton = (this.props.isHead) ? "" : (
      <Link 
        className="my-lists-row-link"
        role="button"
        to={"/my_lists/" + this.props.attributes.id}>
        <span className="glyphicon glyphicon-pencil"></span>
      </Link>
    )
    
    let calendarButton = (this.props.isHead) ? "" : (
      <a href={"/calendars/" + this.props.attributes.id}>
        <span className="glyphicon glyphicon-calendar"></span>
      </a>
    )
    
    return (
      <tr className={"my-lists-row" + (this.props.isSelecting ? " my-lists-row-selecting" : "")}>
        {tds}
        <td key="inv" className="my-lists-row-action-td">
          {calendarButton}
          &nbsp;&nbsp;&nbsp;&nbsp;
          {setUpInventoryButton}
        </td>
      </tr>
    )
  }
  
}