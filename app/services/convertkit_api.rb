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
    #res = HTTParty.get("https://api.convertkit.com/forms?k=#{@api_key}&v=2", {})
    #https://api.convertkit.com/v3/forms?api_secret=SyKalMHlXqoTZ9_qun23P5HTe3YlfOzlpkFRkIGxVDA
    #res = HTTParty.get("https://api.convertkit.com/v3/forms?api_secret=#{@api_key}&v=2", {})
    puts "in get_forms"
    res = HTTParty.get("https://9yafyo0616.execute-api.us-east-1.amazonaws.com/prod/lists/convertkit/forms?api_secret=#{@api_key}", {})
    #puts res
    res.success? ? res : []
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
