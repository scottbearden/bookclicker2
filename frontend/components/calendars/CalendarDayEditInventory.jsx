import React from 'react';
import { grabCsrfToken } from '../../ext/functions';
import { iOS } from '../../ext/userAgent';
import OneDayInventoryApi from '../../api/OneDayInventoryApi';
import NumericInput from 'react-numeric-input';

export default class CalendarDayEditInventory extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = CalendarDayEditInventory.defaultState;
  }
  
  openInventoryForm() {
    this.setState({inventoryFormOpen: true})
  }

  closeForm() {
    this.setState({inventoryFormOpen: false})
  }
  
  componentDidMount() {
    var that = this;
    $('#reusableModal').off('inventory-loaded')
    $('#reusableModal').on('inventory-loaded', function($event, invData) {
      let state = CalendarDayEditInventory.defaultState;
      Object.assign(state, {
        date: invData.date,
        one_day_inventory: invData.one_day_inventory,
        remaining_inventory: invData.remaining_inventory,
        pending_system_bookings: invData.pending_system_bookings,
        accepted_system_bookings: invData.accepted_system_bookings,
        external_bookings: invData.external_bookings
      });
      
      that.setState(state);
    })

  }

  static get defaultState() {
    return { 
      inventorySaving: false,
      external_inv_type: 'solo',
      date: "", 
      book_title: "", 
      book_owner_email: "", 
      book_owner_name: "",
      one_day_inventory: { 
        solo: 0, 
        feature: 0, 
        mention: 0 
      },
      remaining_inventory: { 
        solo: 0, 
        feature: 0, 
        mention: 0 
      },
      inventory_change_error: null,
      mentionLastChangedAt: null
    };
  }
  
  isMentionEchoChange(field) {
    return field == "mention" && this.state.mentionLastChangedAt && Date.now() - this.state.mentionLastChangedAt < 50;
  }
  
  linksHtml() {
    if (this.state.inventoryFormOpen) {
      return (
        <a 
          className={"bclick-button bclick-hollow-dark-red-button"}
          onClick={this.closeForm.bind(this)}>
          <span>Close</span>
        </a>
      )
    } else {
      return (
        <div>
          <a 
            className={"one-day-inventory-form-link bclick-button bclick-hollow-black-button"}
            onClick={this.openInventoryForm.bind(this)}>
            Edit Inventory
          </a>
        </div>
      )
    }
  }

  notInPast() {
    var today = new Date();
    var yesterday = today.setDate(today.getDate() - 1);
    return !this.state.date || Date.parse(this.state.date) > yesterday;
  }
  
  allowedChangeEvent(ev, field) {
    if (!ev) return false;
    if (this.isMentionEchoChange(field)) return false
    if (ev.dataset && ev.dataset.inv_type == field) return true
    if (ev.type == 'readystatechange') return true
    let $invInput = $(ev.target).closest('.one-day-inventory-input');
    return $invInput.length && $invInput.data('inv_type') == field;
  }
  
  changeOneDaySoloFeature(field, event) {
    let value = event.target.checked ? 1 : 0;
    this.handleInventoryChange(value, field, event);
  }

  changeOneDayMentions(value, valueString, eventTarget) {
    let field = 'mention';
    this.handleInventoryChange(value, field, eventTarget);
  }
  
  handleInventoryChange(value, field, event) {
    if (!this.allowedChangeEvent(event, field)) return null;
    
    let one_day_inventory = $.extend({}, this.state.one_day_inventory)
    let { remaining_inventory } = this.state;
    let inventory_change_error = null;

    if (this.isTheoreticallyNotAllowed(field)) {
      if (this.canReduceOthersToZero(field)) {
        if (field == 'solo') {
          one_day_inventory.solo = 1;
          one_day_inventory.feature = 0;
          one_day_inventory.mention = 0;
          remaining_inventory.solo = 1;
          remaining_inventory.feature = 0;
          remaining_inventory.mention = 0;
        } else if (field == 'feature' || field == 'mention') {
          one_day_inventory.solo = 0;
          one_day_inventory[field] = 1;
          remaining_inventory.solo = 0;
          remaining_inventory[field] = 1;
        }
      } else {
        inventory_change_error = 'You cannot change this inventory.  It may already be booked';
      }
    } else {
      let invChange = value - one_day_inventory[field];
      if (invChange < 0 && remaining_inventory[field] <= 0) {
        inventory_change_error = 'You cannot change this inventory.  It may already be booked';
      } else if (invChange) {
        one_day_inventory[field] = value;
        remaining_inventory[field] = remaining_inventory[field] + invChange;
      } else {
        return null;
      }
    }
    
    let mentionLastChangedAt = (one_day_inventory.mention == this.state.one_day_inventory.mention ? this.state.mentionLastChangedAt : Date.now())
    this.setState({one_day_inventory, remaining_inventory, inventory_change_error, mentionLastChangedAt});
  }
  
  canReduceToZero(field) {
    let { one_day_inventory, remaining_inventory } = this.state;
    return one_day_inventory[field] == remaining_inventory[field];
  }
  
  canReduceOthersToZero(field) {
    if (field == 'solo') {
      return this.canReduceToZero('feature') && this.canReduceToZero('mention');
    } else if (field == 'feature' || field == 'mention') {
      return this.canReduceToZero('solo')
    }
  }
  
  isTheoreticallyNotAllowed(inv_type) {
    if (this.state.one_day_inventory[inv_type] > 0) return false;
    if (inv_type == 'feature' || inv_type == 'mention') {
      return this.state.one_day_inventory.solo > 0;
    } else if (inv_type == 'solo') {
      return (this.state.one_day_inventory.feature > 0 || this.state.one_day_inventory.mention > 0);
    }
  }
  
  delayedSaveButtonReset() {
    var that = this
    setTimeout(() => {
      that.setState({inventorySaving: false})
    }, 800)
  }
  
  saveOneDayInventory(event) {
    event.preventDefault();
    if (this.state.inventorySaving) return null;
    
    var that = this;
    that.setState({inventorySaving: true, inventory_change_error: null}, function() {
      OneDayInventoryApi.create(that.props.list.id, that.state.date, that.state.one_day_inventory).then(res => {
        that.setState({inventorySaving: 'success'}, that.delayedSaveButtonReset.bind(that))
        $('#reusableModal').trigger('inventory-changed', res)
      }, errRes => {
        that.setState({inventorySaving: 'error'}, that.delayedSaveButtonReset.bind(that))
      })
    })
  }
  
  saveButtonText() {
    if (this.state.inventorySaving === 'success') {
      return "Saved";
    } else if (this.state.inventorySaving === 'error') {
      return "Error. Did not save";
    } else if (this.state.inventorySaving) {
      return "Saving...";
    } else {
      return "Save Day's Inventory";
    }
  }

  render() {
    let form = "";
    return (
      <div className="external-reservation-form-component">
        {this.linksHtml()}
        
        <div className="external-reservation-form-list-name">List: {this.props.list.adopted_pen_name}</div>
        {this.state.inventoryFormOpen ? <hr style={{marginBottom: '3px'}}/> : ""}

        <div className="external-reservation-form-container" style={{display: this.state.inventoryFormOpen ? 'block' : 'none'}}>
          <form action="#" method="POST" onSubmit={this.saveOneDayInventory.bind(this)}>
            <input type='hidden' name='authenticity_token' value={grabCsrfToken($)} />
            
            <div className="external-reservation-form-inputs">
              <div className="space1"/>
              
              <div data-inv_type="solo" className={"one-day-inventory-input" + (iOS() ? " ios" : "")}>
                <div className="one-day-inventory-input-inv-type">
                 Solo
                </div>
                <input
                  type="checkbox"
                  value="1"
                  checked={this.state.one_day_inventory.solo}
                  onChange={this.changeOneDaySoloFeature.bind(this, 'solo')} />
                  
              </div>

              <div data-inv_type="feature" className={"one-day-inventory-input" + (iOS() ? " ios" : "")}>
                <div className="one-day-inventory-input-inv-type">
                 Feature
                </div>
                <input
                  type="checkbox"
                  data-inv_type="feature"
                  value="1"
                  checked={this.state.one_day_inventory.feature}
                  onClick={this.changeOneDaySoloFeature.bind(this, 'feature')} />
              </div>

              <div data-inv_type="mention" className={"one-day-inventory-input" + (iOS() ? " ios" : "")}>
                <div className="one-day-inventory-input-inv-type">
                 Mentions
                </div>
                <NumericInput
                  name={"mention"}
                  className="mention-input"
                  type="number"
                  data-inv_type="mention"
                  mobile={this.props.isMobile}
                  value={this.state.one_day_inventory.mention}
                  onChange={this.changeOneDayMentions.bind(this)}
                  min={0}
                  max={9}
                  step={1} />
                  
              </div>
              
            </div>
            
            <div className="inventory-change-error">
              {this.state.inventory_change_error}
            </div>
            
            <div className="external-reservation-form-text-submit">
              <input 
                className="bclick-button bclick-solid-mailchimp-gray-button"
                type="submit" 
                disabled={this.state.inventorySaving}
                value={this.saveButtonText()}/>
                
            </div>
            
          </form>
        </div>


      </div>
    )
  }
  
  
}