class MailerliteApi
  MAILERLITE_API_BASE_URI_CLASSIC = "https://api.mailerlite.com/api/v2"
  MAILERLITE_API_BASE_URI_NEW = "https://connect.mailerlite.com"

  attr_accessor :api_key_id, :api_version
  
  def initialize(api_key:, api_version: nil)
    @api_key = api_key
    @api_version = api_version || determine_api_version
  end

  def determine_api_version
    # Step 1: Try to detect by endpoint response
    test_endpoint = "#{MAILERLITE_API_BASE_URI_NEW}/me"
    response = HTTParty.get(test_endpoint, headers_and_auth)

    if response.success?
      "new"
    else
      "classic"
    end
  rescue
    "classic"
  end

  def get_groups
    uri = "#{api_base_uri}/groups?limit=100000"
    res = HTTParty.get(uri, headers_and_auth)
    res.success? ? res : []
  rescue
    []
  end
  
  def get_campaigns
    uri = "#{api_base_uri}/campaigns/sent?limit=100000"
    res = HTTParty.get(uri, headers_and_auth)
    res.success? ? res : []
  rescue
    []
  end

  def subscribe_to_list(list_id, email_address)
    uri = "#{api_base_uri}/groups/#{list_id}/subscribers"
    body_params = { body: { "email" => email_address.downcase } }
    HTTParty.post(uri, headers_and_auth.merge(body_params))
  end

  def unsubscribe_from_list(list_id, email_address)
    uri = "#{api_base_uri}/groups/#{list_id}/subscribers/#{email_address.downcase}"
    HTTParty.delete(uri, headers_and_auth)
  end

  def get_subscribers(list_id)
    uri = "#{api_base_uri}/groups/#{list_id}/subscribers?limit=1000000"
    HTTParty.get(uri, headers_and_auth)
  end
  
  def platform
    "mailerlite"
  end
  
  def get_account_stats
    uri = "#{api_base_uri}/stats"
    res = HTTParty.get(uri, headers_and_auth)
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
      camp[:name] = campaign["name"] # MailerLite API says name inherits from subject
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

  def api_base_uri
    @api_version == "new" ? MAILERLITE_API_BASE_URI_NEW : MAILERLITE_API_BASE_URI_CLASSIC
  end
end
