class Campaign < ApplicationRecord

  include ActionView::Helpers::NumberHelper
  belongs_to :list
  
  after_create :fetch_aweber_preview_url, if: Proc.new { |camp| camp.list.aweber? }

  def emails_sent_delimited
    if emails_sent.present?
      number_with_delimiter(emails_sent)
    end
  end
  
  def num_opens
    if self.open_rate.present? && self.emails_sent.present?
      result = (self.open_rate*self.emails_sent).round
      number_with_delimiter(result)
    end
  end
  
  def num_clicks
    if self.click_rate.present? && self.emails_sent.present?
      result = (self.click_rate*self.emails_sent).round
      number_with_delimiter(result)
    end
  end
  
  def sent_at_pretty
    if sent_at.present?
      sent_at.strftime("%B %d, %Y at %H:%M")
    end
  end

  def fetch_aweber_preview_url
    AweberFetchCampaignPreviewUrlJob.delay.perform(id)
  end

end
