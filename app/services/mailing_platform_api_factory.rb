class MailingPlatformApiFactory
  
  def self.init_api(api_key)
    if api_key.mailchimp?
      if api_key.token.present?
        result = MailchimpApi.new(token: api_key.token, api_data_center: api_key.api_dc)
      else
        result = MailchimpApi.new(api_key: api_key.key)
      end
    elsif api_key.aweber?
      result = AweberApi.new(access_token: api_key.token, access_secret: api_key.secret)
    elsif api_key.mailerlite?
      result = MailerliteApi.new(api_key: api_key.key)
    elsif api_key.convertkit?
      result = ConvertkitApi.new(api_key: api_key.key)
    else
      raise "Unknown ApiKey platform: api_key_id: #{api_key.id}"
    end
    result.api_key_id = api_key.id
    result
  end
  
end