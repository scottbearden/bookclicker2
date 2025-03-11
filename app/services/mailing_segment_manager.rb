class MailingSegmentManager
  
  MAILCHIMP_USER_ID = 107
  MAILCHIMP_LIST_ID = "78d85f08da"
  
  MAILCHIMP_SEGMENT_ID = {
    production: "48027",
    development: "48023"
  }
  
  def api
    @api ||= User.find(MAILCHIMP_USER_ID).api_keys.mailchimp.first.init_api
  end
  
  def add(user)
    res_a = api.subscribe_to_list(MAILCHIMP_LIST_ID, user.email)
    res_b = api.add_to_segment(MAILCHIMP_LIST_ID, MAILCHIMP_SEGMENT_ID[Rails.env.to_sym], user.email)
    if res_b.code.between?(200, 299)
      UserEvent.create!(
        user_id: user.id, 
        event: 'subscribe', 
        event_detail: {email: user.email}.to_json
      )
    end
    res_b
  end

  def remove(user, email_address)
    res = api.remove_from_segment(MAILCHIMP_LIST_ID, MAILCHIMP_SEGMENT_ID[Rails.env.to_sym], email_address)
    if res.code.between?(200, 299) && user
      UserEvent.create!(
        user_id: user.id, 
        event: 'unsubscribe', 
        event_detail: {email: email_address}.to_json
      )
    end
    res
  end
  
  def list_segment_members
    res = api.get_segments_members(MAILCHIMP_LIST_ID, MAILCHIMP_SEGMENT_ID[Rails.env.to_sym])
    res.parsed_response["members"].map { |m| m["email_address"] }
  end
  
end
