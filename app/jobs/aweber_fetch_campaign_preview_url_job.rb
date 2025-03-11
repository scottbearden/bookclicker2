# frozen_string_literal: true

class AweberFetchCampaignPreviewUrlJob
  include Sidekiq::Worker

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    api = campaign.list.api_key.init_api
    campaign.preview_url = api.get_campaign_preview_url(campaign.list.platform_id, campaign.platform_id)
    campaign.save!
  end
end
