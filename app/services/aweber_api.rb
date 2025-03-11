class AweberApi
  
  attr_reader :client
  attr_accessor :api_key_id
  
  def initialize(oauth: nil, access_token: nil, access_secret: nil)
    oauth ||= AweberApi.init_oauth
    if access_token && access_secret
      oauth.authorize_with_access(access_token, access_secret)
    end
    @client = AWeber::Base.new(oauth)
  end
  
  def self.init_oauth
    AWeber::OAuth.new(
      Figaro.env.aweber_consumer_key, 
      Figaro.env.aweber_consumer_secret)
  end
  
  def account_id
    @account_id ||= client.account.id
  rescue
    nil
  end
  
  def status
    account_id.present? ? "Good" : "Bad"
  end

  def subscribe_to_list(list_id, email_address)
    new_subscriber = {}
    new_subscriber["email"] = email_address.downcase
    new_subscriber["name"] = "Bookclicker Client"
    client.account.lists[list_id.to_i].subscribers.create(new_subscriber)
  end

  def unsubscribe_from_list(list_id, email_address)
    subscriber = client.account.lists[list_id.to_i].subscribers.find_by_email(email_address.downcase)
    if !subscriber.present?
      raise "Could not find subscriber #{email_address.downcase}"
    else
      subscriber.delete()
    end
  end
  
  def get_lists(with_stats: false, request_url: nil)
    result = []
    res = client.account.get(request_url || "//api.aweber.com/1.0/accounts/#{account_id}/lists?ws.size=100")
    res["entries"].each do |list_data|
      list_attrs = {}
      list_attrs[:id] =  list_data["id"]
      list_attrs[:name] = list_data["name"]
      list_attrs[:active_member_count] = list_data["total_subscribed_subscribers"]
      if with_stats
        begin
          campaigns_url = list_data["campaigns_collection_link"] + "?ws.size=100" if list_data["campaigns_collection_link"]
          campaigns_data = []
          while campaigns_url.present?
            campaigns_response = client.account.get(campaigns_url)
            campaigns_data.concat(campaigns_response["entries"])
            campaigns_url = campaigns_response["next_collection_link"]            
          end
          sent = clicks = opens = 0
          while campaigns_data.present?
            cdata = campaigns_data.shift
            next if cdata["total_clicks"].blank? || cdata["total_opens"].blank? || cdata["total_sent"].blank?
            sent += cdata["total_sent"]
            clicks += cdata["total_clicks"]
            opens += cdata["total_opens"]
          end
          list_attrs[:sent] = sent
          list_attrs[:clicks] = [clicks, sent].min
          list_attrs[:opens] = [opens, sent].min
        rescue => e
          puts e.message
        end
      end
      result << list_attrs
      if res["next_collection_link"].present?
        result.concat(get_lists(with_stats: with_stats, request_url: res["next_collection_link"]))
      end
    end
    result
  rescue
    []
  end

  def get_subscribers(list_id)
    #you can call .email, .delete and other api calls on each resulting element
    client.account.lists[list_id.to_i].subscribers.map { |s| s[1] }
  end

  def retrieve_email_campaigns(list_id, request_url: nil)
    
    begin
      res = client.account.get(request_url || "//api.aweber.com/1.0/accounts/#{account_id}/lists/#{list_id}/campaigns?ws.size=100")
    rescue NameError, AWeber::NotFoundError => e
      puts "AWeber::NotFoundError: #{e.message}"
      res = {}
    end
    
    result = []
    res["entries"].present? and res["entries"].select { |c| c["sent_at"].present? }.each do |campaign|
      camp = {}
      camp[:platform_id] = campaign["id"]
      camp[:sent_on] = Date.parse(campaign["sent_at"])
      camp[:sent_at] = DateTime.parse(campaign["sent_at"])
      
      camp[:subject] = campaign["subject"]
      camp[:emails_sent] = campaign["total_sent"]
      camp[:open_rate] = campaign["total_sent"].to_i == 0 ? 0.0 : campaign["total_opens"].to_f/campaign["total_sent"]
      camp[:click_rate] = campaign["total_sent"].to_i == 0 ? 0.0 : campaign["total_clicks"].to_f/campaign["total_sent"]
      
      result << camp
    end
    if res["next_collection_link"].present?
      result.concat(retrieve_email_campaigns(list_id, request_url: res["next_collection_link"]))
    end
    result
  end

  def get_campaign_preview_url(list_id, campaign_id)
    client.account.get("//api.aweber.com/1.0/accounts/#{account_id}/lists/#{list_id}/broadcasts/#{campaign_id}")["archive_url"]
  end
  
  def platform
    "aweber"
  end
  
end
