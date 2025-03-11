import React from 'react';
import Select from 'react-select';
import { hex, isURL, validateEmail } from '../../ext/functions';
import ConfirmPromosApi from '../../api/ConfirmPromosApi';
import ReservationInfo from '../reservations/ReservationInfo';

const CAMPAIGNS_OFFSET = 5

const BUTTON_CSS = {
  "disabled-confirmed": "bclick-button bclick-solid-sky-blue-button no-hover-change opacity-6",
  "disabled-not-confirmed": "bclick-button bclick-hollow-light-grey-button no-hover-change",
  "confirmed": "bclick-button bclick-solid-sky-blue-button",
  "not-confirmed": "bclick-button bclick-hollow-sky-blue-button"
}

export default class ConfirmPromoSelect extends React.Component {

  constructor(props) {
    super(props);
    this.state = { 
      campaign_id: this.initialCampaignId(),
      last_campaign_id_submitted: this.props.reservation.confirmed_campaign_id,
      campaign_preview_url: this.props.reservation.manual_campaign_preview_url,
      last_campaign_preview_url_submitted: this.props.reservation.manual_campaign_preview_url,
      recipient_email: this.props.reservation.internal ? null : this.props.reservation.book_owner_email,
      last_recipient_email_submitted: this.props.reservation.internal ? null : this.props.reservation.book_owner_email,
      promo_was_confirmed: this.props.reservation["send_confirmed?"],
      campaigns: this.props.reservation.list.campaigns_last_5,
      can_load_more: this.props.reservation.list.campaigns_last_5.length === CAMPAIGNS_OFFSET,
      offset: CAMPAIGNS_OFFSET,
      hexId: "confirm-promo-selector-" + hex(12),
      showAddPreviewLinkInput: this.initialCampaignId() == 'add_preview_link'
    };
  }
  
  initialCampaignId() {
    if (this.props.reservation.confirmed_campaign_id) {
      return this.props.reservation.confirmed_campaign_id
    } else if (this.props.reservation.manual_campaign_preview_url) {
      return 'add_preview_link'
    } else {
      return null;
    }
  }

  confirmedCampaignIdSelectChangeHandler(selection) {
    var that = this;
    var selectInput = this.refs.selectInput;
    if (selection) {
      if (selection.value == 'more') {
        selectInput.setState({isOpen: true}, function() {
          that.scrollToBottomOfSelectMenu();
        })
        ConfirmPromosApi.fetchCampaigns(this.props.reservation.list_id, this.state.offset).then(res => {
          let campaigns = this.state.campaigns.concat(res.campaigns);
          let campaign_id = null;
          let { can_load_more, offset } = res;
          this.setState({campaign_id, campaigns, can_load_more, offset})
        })
      } else if (selection.value == 'add_preview_link') {
        this.setState({campaign_id: selection.value, showAddPreviewLinkInput: true});
      } else {
        this.setState({campaign_id: selection.value, showAddPreviewLinkInput: false});
      }
    } else  {
      this.setState({campaign_id: null, showAddPreviewLinkInput: false});
    }
    
  }
  
  scrollToBottomOfSelectMenu() {
    var cssSelection = "#" + this.state.hexId + " .Select-menu"
    $(cssSelection).scrollTop($(cssSelection)[0].scrollHeight);
  }
  
  campaignAsSelectLabel(campaign) {
    return (
      <div className="campaign-option-label">
        <span className={"subject"}>{campaign.name || campaign.subject}</span>
          <br/>
        Number of Emails: {campaign.emails_sent}
          <br/>
        Date: {campaign.sent_on}
          <br/>
        {campaign.preview_url ? "Preview Link Available" : " "}
          <br/>
      </div>
    )
  }
  
  loadMoreAsSelectLabel() {
    return (
      <div className="campaign-option-label load-more">
        <a>Load More Campaigns</a>
      </div>
    )
  }
  
  addPreviewLinkAsSelectLabel() {
    return (
      <div className="campaign-option-label" style={{textAlign: 'center'}}>
        <a>{this.state.last_campaign_preview_url_submitted ? 'Preview Link' : 'Add Preview Link'}</a>
      </div>
    )
  }

  campaignSelectOptions() {
    let results = [];
    
    if (this.props.reservation.confirmed_campaign) {
      let campaign = this.props.reservation.confirmed_campaign;
      results.push({value: campaign.id, label: this.campaignAsSelectLabel(campaign)})
    }
    
    this.state.campaigns.forEach((campaign, idx) => {
      results.push({value: campaign.id, label: this.campaignAsSelectLabel(campaign)})
    });
    
    if (this.state.can_load_more) {
      results.push({value: 'more', label: this.loadMoreAsSelectLabel()})
    }
    
    if (!results.length) {
      results.push({value: 'add_preview_link', label: this.addPreviewLinkAsSelectLabel() })
    }
    
    let values = results.map(option => { return option.value });
    return results.filter((option, index, self) => { 
      return values.indexOf(option.value) === index; 
    });
  }
  
  selectMenu() {
    let options = this.campaignSelectOptions();
    let previewUrlInputOnly = options.length === 1 && options[0].value === 'add_preview_link';
    return (
      <Select
        clearable={true}
        ref='selectInput'
        placeholder={previewUrlInputOnly ? "Provide Confirmation Info" : "Select Email Campaign"}
        autoBlur={true}
        searchable={false}
        value={this.state.campaign_id || ''}
        options={options}
        onChange={this.confirmedCampaignIdSelectChangeHandler.bind(this)} />
    )
  }
  
  changeBookOwnerEmail(event) {
    this.setState({recipient_email: event ? event.target.value : null})
  }
  
  bookOwnerEmailInput() {
    if (!this.props.reservation.internal) {
      return (
        <div className="confirm-promo-add-preview-link-input-container">
          <input 
            type="text" 
            className='form-control'
            placeholder={this.state.recipient_email ? '' : "Author email"}
            onChange={this.changeBookOwnerEmail.bind(this)}
            value={this.state.recipient_email || ''} />
        </div>
      )
    }
  }
  
  changeCampaignPreviewUrl(event) {
    this.setState({campaign_preview_url: event ? event.target.value : null})
  }
  
  campaignPreviewUrlInput() {
    if (this.state.showAddPreviewLinkInput) {
      return (
        <div className="confirm-promo-add-preview-link-input-container">
          <input 
            type="text" 
            className="form-control"
            value={this.state.campaign_preview_url || ''}
            onChange={this.changeCampaignPreviewUrl.bind(this)}
            placeholder="Preview Link"/>
        </div>
      )
    }
  }

  saveSelection(event) {
    event.preventDefault();
    var that = this;
    if (this.state.saving) return null;
    this.setState({saving: true, saveError: null, saveWarning: null}, function() {
      ConfirmPromosApi.create(
        this.props.reservation.id, 
        this.props.reservation.clazz, 
        this.state.campaign_id, 
        this.state.campaign_preview_url,
        this.state.recipient_email
      ).then(success => {
        this.setState({
          saving: false, 
          last_campaign_id_submitted: this.state.campaign_id, 
          last_campaign_preview_url_submitted: this.state.campaign_preview_url,
          last_recipient_email_submitted: this.state.recipient_email,
          promo_was_confirmed: true
        }, function() {
          setTimeout(function() {
            that.props.onConfirm && that.props.onConfirm();
          }, 700)
        })
      }, err => {
        this.setState({saving: false, saveError: (err.responseJSON ? err.responseJSON.message : 'Did not save')})
      })
    })
    
  }

  saveSelectionStubbed(event) {
    event.preventDefault();
    var that = this;
    this.setState({saveWarning: this.saveDisabled()})
    return null;
  }
  
  recipientEmailMissing() {
    return !this.props.reservation.internal && !validateEmail(this.state.recipient_email)
  }
  
  previewLinkMissing() {
    return this.state.campaign_id == 'add_preview_link' && !isURL(this.state.campaign_preview_url)
  }
  
  recipientEmailUnchanged() {
    return this.state.recipient_email && this.state.recipient_email == this.state.last_recipient_email_submitted
  }
  
  sameCampaignInfo() {
    if (this.state.campaign_id > 0) {
      return this.state.campaign_id == this.state.last_campaign_id_submitted
    } else if (this.state.campaign_id == 'add_preview_link') {
      return this.state.campaign_preview_url && this.state.campaign_preview_url == this.state.last_campaign_preview_url_submitted
    }
  }
  
  noChangesToSubmit() {
    return this.sameCampaignInfo() && (this.recipientEmailUnchanged() || this.props.reservation.internal)
  }
  
  saveDisabled() {
    if (this.recipientEmailMissing()) {
      return "Valid email required"
    } else if (this.noChangesToSubmit()) {
      return "There are no changes to submit";
    } else if (this.previewLinkMissing()) {
      return "Preview link missing";
    } else if (!this.state.campaign_id) {
      return "Information missing";
    }
  }
  
  buttonStyle() {
    if (this.theresAnErrorAndTheyKnowIt()) {
      
      return this.state.promo_was_confirmed ? BUTTON_CSS["disabled-confirmed"] : BUTTON_CSS["disabled-not-confirmed"]
    
    } else if (this.state.promo_was_confirmed) {
      
      return BUTTON_CSS["confirmed"]
    
    } else {
      
      return BUTTON_CSS["not-confirmed"]
    
    }
  }
  
  theresAnErrorAndTheyKnowIt() {
    return this.saveDisabled() && this.state.saveWarning 
  }

  saveButton() {
    
    return (
      <div className="save-button-wrapper" style={{float: 'left'}}>
        <a 
          className={this.buttonStyle()}
          disabled={this.saveDisabled() || this.state.saving}
          onClick={this.saveDisabled() ? this.saveSelectionStubbed.bind(this) : this.saveSelection.bind(this)}>
          {this.submitButtonText()}
        </a>
      </div>
    )
  }
  
  previewLink() {
    let allCampaignOptions = [];
    if (this.props.reservation.confirmed_campaign) {
      allCampaignOptions.push(this.props.reservation.confirmed_campaign)
    }
    
    this.state.campaigns.forEach(campaign => {
      allCampaignOptions.push(campaign)
    })

    let selectedCampaign = this.state.campaign_id && allCampaignOptions.find(camp => { 
      return camp.id === this.state.campaign_id 
    });
    if (selectedCampaign && selectedCampaign.preview_url) {
      return (
        <div className="save-button-wrapper" style={{float: 'right'}}>
          <a href={selectedCampaign.preview_url} target="_blank" className="bclick-button bclick-button bclick-hollow-blue-button">Preview</a>
        </div>
      )
    }
  }
  
  submitButtonText() {
    if (this.state.saving) {
      return "Saving..."
    } else if (this.state.promo_was_confirmed) {
      if (!this.saveDisabled()) {
        return "Update Confirmation";
      } else {
        return "Confirmed";
      }
    } else {
      return "Send Confirmation";
    }
  }

  selectPrompt() {
    
    if (this.state.saveError) {
      return <span className="promo-confirmed-error">{this.state.saveError}</span>;
    } else if (this.state.promo_was_confirmed) {
      return <span className="promo-confirmed-notice">Your promo has been confirmed</span>;
    } else {
      return <span>If you sent this promo, please select it from the dropdown</span>;
    }
  }
  
  saveError() {
    return <div className="error-confirming-promo">{this.theresAnErrorAndTheyKnowIt()}</div>
  }
  
  render() {
    return (
      <div className="confirm-promo-select-wrapper" id={this.state.hexId}>
        <div className="confirm-promo-select-title">
          {this.props.reservation.inv_type.capitalize()} for <i>{this.props.book.title || this.props.book.author}</i> on {this.props.reservation.date_pretty}
        </div>
        <div className="confirm-promo-float-flex">

          <div className="confirm-promo-float-flex-select-col">
            <div className="confirm-promo-float-flex-select-wrapper">
              <div className="confirm-promo-select-header">
                {this.selectPrompt()}
              </div>
              {this.selectMenu()}
              {this.campaignPreviewUrlInput()}
              {this.bookOwnerEmailInput()}
              {this.saveButton()}
              {this.previewLink()}
              {this.saveError()}
            </div>
          </div>
          
          
          <div className="confirm-promo-float-flex-info-col">
            <ReservationInfo 
              {...this.props}
              limitedInfo={true} />
          </div>
          
        </div>
      </div>
    )
  }

}