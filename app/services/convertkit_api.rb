class ConvertkitApi 
  
  attr_accessor :api_key_id
  
  def initialize(api_key:)
    @api_key = api_key
  end
  
  def platform
    "convertkit"
  end
  
  def status
    get_forms.present? ? "Good" : "Bad"
  end
  
  def get_forms
    url = "https://api.convertkit.com/v3/forms?api_secret=#{@api_key}"
    res = HTTParty.get(url, {})
    forms = res.success? ? res.parsed_response["forms"] : []
    forms.each do |form|
      form_url = "https://api.convertkit.com/v3/forms/#{form['id']}/subscriptions?api_secret=#{@api_key}"
      form_res = HTTParty.get(form_url, {})
      if form_res.success?
        form['total_subscriptions'] = form_res.parsed_response['total_subscriptions']
      else
        form['total_subscriptions'] = 0
      end
    end
    forms
  rescue
    []
  end
  
  def retrieve_email_campaigns(platform_id)
    []#Not Supported by ConverKit
  end
  
  def subscribe_to_form(form_id, email_address, first_name = nil)
    #post_url = "https://api.convertkit.com/forms/#{form_id}/subscribe?k=#{@api_key}&email=#{email_address}"
    #https://api.convertkit.com/v3/forms/<form_id>/subscribe
    post_url = "https://api.convertkit.com/v3/forms/#{form_id}/subscribe"
    response = HTTParty.post(post_url, body: {api_secret: @api_key, email: email_address}).to_json 
    puts response
  end
  
  def unsubscribe_from_form(form_id, email_address)
    #post_url = "https://api.convertkit.com/forms/#{form_id}/unsubscribe?k=#{@api_key}&email=#{email_address}"
    #https://api.convertkit.com/v3/unsubscribe

    post_url = "https://api.convertkit.com/v3/unsubscribe"
    response = HTTParty.post(post_url, body: {api_secret: @api_key, email: email_address}).to_json
    puts response
  end
  
end
