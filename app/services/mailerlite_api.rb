class MailerliteApi
  
  MAILERLITE_API_BASE_URI = "https://api.mailerlite.com/api/v2"

  attr_accessor :api_key_id
  
  def initialize(api_key:)
    @api_key = api_key
  end
  
  def get_groups
    res = HTTParty.get("#{MAILERLITE_API_BASE_URI}/groups?limit=100000", headers_and_auth)
    res.success? ? res : []
  rescue
    []
  end
  
  def get_campaigns
    res = HTTParty.get("#{MAILERLITE_API_BASE_URI}/campaigns/sent?limit=100000", headers_and_auth)
    res.success? ? res : []
  rescue
    []
  end

  def subscribe_to_list(list_id, email_address)
    body_params = {
      body: {
        "email" => email_address.downcase
      }
    }
    HTTParty.post("#{MAILERLITE_API_BASE_URI}/groups/#{list_id}/subscribers", 
      headers_and_auth.merge(body_params))
  end

  def unsubscribe_from_list(list_id, email_address)
    HTTParty.delete("#{MAILERLITE_API_BASE_URI}/groups/#{list_id}/subscribers/#{email_address.downcase}",
      headers_and_auth)
  end

  def get_subscribers(list_id)
    HTTParty.get("#{MAILERLITE_API_BASE_URI}/groups/#{list_id}/subscribers?limit=1000000", 
      headers_and_auth)
  end
  
  def platform
    "mailerlite"
  end
  
  def get_account_stats
    res = HTTParty.get("#{MAILERLITE_API_BASE_URI}/stats", 
      headers_and_auth)
  rescue
    {}
  end
  
  def status
    res = get_account_stats
    if res.present? && res.code.between?(200, 299)
      "Good"
    else
      "Bad"
    end
  end

  def retrieve_email_campaigns(list_id)
    campaigns = get_campaigns
    result = []
    campaigns.each do |campaign|
      camp = {}
      camp[:platform_id] = campaign["id"]
      camp[:emails_sent] = campaign["total_recipients"]
      camp[:sent_on] = Date.parse(campaign["date_send"])
      camp[:sent_at] = DateTime.parse(campaign["date_send"])
      camp[:status] = campaign["status"]
      camp[:open_rate] = campaign["opened"]["rate"]/100.0
      camp[:click_rate] = campaign["clicked"]["rate"]/100.0
      camp[:subject] = campaign["name"]
      camp[:name] = campaign["name"] #mailerlite api says name inheretis from subject
      result << camp
    end
    result
  end
  
  private
  
  def headers_and_auth
    {
      :headers => {
        "X-MailerLite-ApiKey" => @api_key,
        "Content-Type" => "application/json"
      }
    }
  end
  
end
