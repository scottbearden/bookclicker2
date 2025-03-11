class MailchimpApi
  
  AUTHORIZE_URI = 'https://login.mailchimp.com/oauth2/authorize' 
  ACCESS_TOKEN_URI = 'https://login.mailchimp.com/oauth2/token'
  
  attr_accessor :api_key_id
  
  def self.authorize_url(redirect_uri: )
    result = AUTHORIZE_URI
    result += "?response_type=code"
    result += "&client_id=#{Figaro.env.mailchimp_client_id}"
    result += "&redirect_uri=#{redirect_uri}"
    result
  end
  
  def self.get_access_token(code:, redirect_uri:)
    options = { 
      :body => {
        :grant_type => "authorization_code",
        :client_id => Figaro.env.mailchimp_client_id,
        :client_secret => Figaro.env.mailchimp_client_secret,
        :code => code,
        :redirect_uri => redirect_uri
      }
    }
    res = HTTParty.post(ACCESS_TOKEN_URI, options)
    res["access_token"] if res.success?
  end
  
  def initialize(api_key: nil, token: nil, api_data_center: nil)
    @api_key = api_key
    @token = token
    @api_data_center = api_data_center || extract_dc_from_key(@api_key)
  end
  
  def get_metadata
    HTTParty.get("https://login.mailchimp.com/oauth2/metadata", headers_and_auth)
  rescue
    {}
  end
  
  def status
    res = get_metadata
    res.present? && res.code.between?(200,209) ? "Good" : "Bad"
  end
  
  def get_lists
    res = HTTParty.get(api_endpoint + "/3.0/lists?count=#{100000}", headers_and_auth)
    Raven.extra_context(mailchimp_res: res.parsed_response)
    JSON.parse(res.body)["lists"] || []
  rescue
    []
  end
  
  def get_campaigns
    res = HTTParty.get(api_endpoint + "/3.0/campaigns?count=#{100000}", headers_and_auth)
    JSON.parse(res.body)["campaigns"] || []
  rescue
    []
  end
  
  def get_segments(list_id)
    HTTParty.get(api_endpoint + "/3.0/lists/#{list_id}/segments?count=#{100000}", headers_and_auth)
  end
  
  def get_segments_members(list_id, segment_id)
    HTTParty.get(api_endpoint + "/3.0/lists/#{list_id}/segments/#{segment_id}/members?count=#{100000}", headers_and_auth)
  end
  
  def get_list_member_status(list_id, email_address)
    subscriber_hash = Digest::MD5.hexdigest(email_address.downcase)
    HTTParty.get(api_endpoint + "/3.0/lists/#{list_id}/members/#{subscriber_hash}", headers_and_auth)
  end
  
  def get_merge_fields(list_id)
    res = HTTParty.get(api_endpoint + "/3.0/lists/#{list_id}/merge-fields", headers_and_auth)
    Raven.extra_context(mailchimp_res: res.parsed_response)
    if res.code.between?(200, 209)
      JSON.parse(res.body)["merge_fields"].select { |field| field["required"] }.map { |field| field["name"] }
    else
      []
    end
  end
  
  def create_segment(list_id, segment_name)
    body_params = {
      body: {
        name: segment_name,
        static_segment: []
      }.to_json
    }
    HTTParty.post(api_endpoint + "/3.0/lists/#{list_id}/segments", 
      headers_and_auth.merge(body_params))
  end
  
  def add_to_segment(list_id, segment_id, email_address)
    body_params = {
      body: {
        "email_address" => email_address
      }.to_json
    }
    HTTParty.post(api_endpoint + "/3.0/lists/#{list_id}/segments/#{segment_id}/members", 
      headers_and_auth.merge(body_params))
  end

  def remove_from_segment(list_id, segment_id, email_address)
    subscriber_hash = Digest::MD5.hexdigest(email_address.downcase)
    HTTParty.delete(api_endpoint + "/3.0/lists/#{list_id}/segments/#{segment_id}/members/#{subscriber_hash}", 
      headers_and_auth)
  end
  
  def subscribe_to_list(list_id, email_address, first_name = nil, last_name = nil)
    body = {
      "email_address" => email_address,
      "status" => "subscribed"
    }
    merge_fields_required = get_merge_fields(list_id)
    merge_fields_data = {}
    
    if merge_fields_required.include?("First Name")
      merge_fields_data["FNAME"] =  first_name
    end
    if merge_fields_required.include?("Last Name")
      merge_fields_data["LNAME"] =  last_name
    end
    
    if merge_fields_data.present?
      body.merge!({merge_fields: merge_fields_data})
    end
    
    HTTParty.post(api_endpoint + "/3.0/lists/#{list_id}/members", 
      headers_and_auth.merge({ body: body.to_json }))
  end

  def unsubscribe_from_list(list_id, email_address)
    subscriber_hash = Digest::MD5.hexdigest(email_address.downcase)
    HTTParty.delete(api_endpoint + "/3.0/lists/#{list_id}/members/#{subscriber_hash}", headers_and_auth)
  end
  
  def headers_and_auth
    if @token
      {
        :headers => { 
          "Accept" => "application/json",
          "Authorization" => "OAuth #{@token}" 
        }
      }
    elsif @api_key
      {
        :headers => { 
          "Accept" => "application/json"
        },
        :basic_auth => {
          :username => "anystring",
          :password => @api_key
        }
      }
    end
  end
  
  def api_endpoint
    "https://#{@api_data_center}.api.mailchimp.com"
  end
  
  def platform
    "mailchimp"
  end

  def retrieve_email_campaigns(list_id)
    res = HTTParty.get(api_endpoint + "/3.0/campaigns?list_id=#{list_id}&count=100000", headers_and_auth)
    result = []
    res.success? and JSON.parse(res.body)["campaigns"].each do |campaign|
      next unless campaign["status"] == "sent"
      camp = {}
      camp[:platform_id] = campaign["id"]
      camp[:sent_on] = Date.parse(campaign["send_time"])
      camp[:sent_at] = DateTime.parse(campaign["send_time"])
      camp[:status] = campaign["status"]
      camp[:emails_sent] = campaign["emails_sent"]
      camp[:open_rate] = campaign["report_summary"].try(:[], "open_rate")
      camp[:click_rate] = campaign["report_summary"].try(:[], "click_rate")
      camp[:subject] = campaign["settings"]["subject_line"].to_s
      camp[:name] = campaign["settings"]["title"]
      camp[:preview_url] = campaign["archive_url"]
      result << camp     
    end
    result
  end
  
  private
  
  def extract_dc_from_key(api_key)
    api_key and api_key.match(/-(us[0-9]+$)/).try(:[],1)
  end
  
end
