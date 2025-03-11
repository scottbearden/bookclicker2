import React from 'react';
import PageTitle from '../PageTitle';
import { iOS } from '../../ext/userAgent';
import PaymentInfoApi from '../../api/PaymentInfoApi';

import EditCardForm from './EditCardForm';
import AddCardForm from './AddCardForm';


export default class PaymentSource extends React.Component {
  
  
  constructor(props) {
    super(props)
    this.state = {}
  }
  
  linksDisabled() {
    return this.state.makingApiCall;
  }
  
  toggleEditingCard(value) {
    this.setState({editingCard: value});
  }
  
  brand() {
    return (
      <div className="pen-name-pill-item">
        <div className="pen-name-pill-item-content">
          {this.props.source.brand}
        </div>
      </div>
    )
  }
  
  cardholderName() {
    return (
      <div className="pen-name-pill-item">
        <div className="pen-name-pill-item-content">
          {this.props.source.name}
        </div>
      </div>
    )
  }
  
  cardAddress() {
    return (
      <div className="pen-name-pill-item">
        <div className="pen-name-pill-item-content">
          {this.props.source.address_line1 || this.props.source.address_city || 'no billing address'}
        </div>
      </div>
    )
  }
  
  cardZip() {
    return (
      <div className="pen-name-pill-item">
        <div className="pen-name-pill-item-content">
          {this.props.source.address_zip}
        </div>
      </div>
    )
  }
  
  cardNumber() {
    return (
      <div className={"pen-name-pill-item"}>
        <div className="pen-name-pill-item-content">
          {this.cardId()}
        </div>
      </div>
    )
  }
  
  cardId() {
    if (this.props.source.last4) {
      return <span>************{this.props.source.last4}</span>
    } else {
      return <span>{this.props.source.card_id}</span>
    }
  }
  
  defaultStatus() {
    return (
      <div className="pen-name-pill-item then-45 delete-source">
        <div className={"pen-name-pill-item-content delete-source-button"}>
          <button 
            onClick={this.props.isDefault ? (e) => { e.preventDefault() } : this.setAsDefault.bind(this) }
            style={{cursor: (this.linksDisabled() || this.props.isDefault) ? 'default' : 'pointer' }}
            className={"bclick-button bclick-small-button" + (this.props.isDefault ? " bclick-solid-mailchimp-gray-button" : " bclick-hollow-mailchimp-gray-button")}>
            {this.props.isDefault ? "Is Default" : "Set Default"}
          </button>
        </div>
      </div>
    )
  }
  
  deleteCard() {
    return (
      <div className="pen-name-pill-item then-45 delete-source">
        <div className={"pen-name-pill-item-content delete-source-button"}>
          <button 
           onClick={this.deleteSource.bind(this)}
           className="bclick-button bclick-small-button bclick-hollow-youtube-red-button">Delete</button>
        </div>
      </div>
    )
  }
  
  editCard() {
    return (
      <div className="pen-name-pill-item then-45 delete-source">
        <div className={"pen-name-pill-item-content delete-source-button"}>
          <button 
           onClick={this.toggleEditingCard.bind(this, true)}
           className="bclick-button bclick-small-button bclick-hollow-aqua-button">Edit</button>
        </div>
      </div>
    )
  }
  
  blankThird() {
    return (
      <div className="pen-name-pill-item blank-third">
        <div className="pen-name-pill-item-content">
          &nbsp;
        </div>
      </div>
    )
  }
  
  strongThird() {
    return (
      <div className="pen-name-pill-item">
        <div className="pen-name-pill-item-content">
          &nbsp;
        </div>
      </div>
    )
  }
  
  cardActions() {
    if (this.props.source.id) {
      return (
        <div className="pen-name-pill-content">
          <div className='clearfix'>
            {this.defaultStatus()}
            {this.editCard()}
            {this.deleteCard()}
          </div>
        </div>
      )
    }
  }
  
  card() {
    return (
      <div className="pen-name-pill-content card-info-row">
        <div className='clearfix'>
          {this.brand()}
          {this.cardNumber()}
          {this.expiration()}
        </div>
      </div>
    )
  }
  
  cardNameAddress() {
    return (
      <div className="pen-name-pill-content card-address-row">
        <div className='clearfix'>
          {this.cardholderName()}
          {this.cardAddress()}
          {this.cardZip()}
        </div>
      </div>
    )
  }
  
  newCard() {
    return (
      <div className="pen-name-pill-content">
        <div className='clearfix'>
          {this.strongThird()}
          <div className="pen-name-pill-item">
            <div className="pen-name-pill-item-content">
              Add New Card
            </div>
          </div>
          {this.strongThird()}
        </div>
        <AddCardForm stripeSetupIntent={this.props.stripeSetupIntent} />
      </div>
    )
  }
  
  expiration() {
    return (
      <div className="pen-name-pill-item">
        <div className="pen-name-pill-item-content">
         {this.props.source.exp_month}/{this.props.source.exp_year}
        </div>
      </div>
    )
  }
  
  render() {
    if (this.state.editingCard) {
      
      return (
        <div className={"pen-name-pill-wrapper" + (this.linksDisabled() ? " doing-stuff" : "")}>
          {this.props.source.id ? this.card() : null}
          <EditCardForm 
            cancelEditingCard={this.toggleEditingCard.bind(this, false)}
            card={this.props.source}/>
        </div>
      )
      
    } else {
      
      return (
        <div className={"pen-name-pill-wrapper" + (this.linksDisabled() ? " doing-stuff" : "")}>
          {this.props.source.id ? this.card() : this.newCard()}
          {this.props.source.id ? this.cardNameAddress() : null}
          {this.props.source.id ? this.cardActions() : null}
        </div>
      )
      
    }
    
  }
  
  deleteSource(event) {
    event.preventDefault();
    if (this.state.makingApiCall) return null;
    
    if (!confirm('Delete this payment info?')) {
      return null;
    }
    
    var that = this
    this.setState({makingApiCall: true}, function() {
      PaymentInfoApi.delete(this.props.source.id).then(res => {
        that.setState({makingApiCall: false}, function() {
          that.props.propagateState({sources: res.sources}, function() {
            that.props.establishDefaultSource()
          })
        })
      }, errRes => {
        that.setState({makingApiCall: false}, function() {
          alert('Could not delete card.')
        })
      })
    })
  }
  
  setAsDefault(event) {
    event.preventDefault();
    if (this.state.makingApiCall) return null;
    
    var that = this;
    
    this.setState({makingApiCall: true}, function() {
      PaymentInfoApi.setDefaultSource(this.props.source.card_id).then(res => {
        that.setState({makingApiCall: false}, function() {
          that.props.propagateState({defaultSourceId: res.default_source_id})
        })
      }, errRes => {
        that.setState({makingApiCall: false}, function() {
          alert('There was an error updating your default payment source')
        })
      })
    })
    
  }
  
}
