class MailchimpOauthUserManager
  
  def self.create_user_from_oauth(data, token)
    raise "Invalid MailChimp data" unless data["user_id"].present? && data["login"]["email"].present?

    user = User.new({
      role: 'full_member',
      name: data["accountname"],
      email: data["login"]["email"],
      skip_email_verification: true,
      password: data["user_id"].to_s
    })

    if user.save
      api_key = user.api_keys.new(
        platform: 'mailchimp',
        account_id: data["user_id"],
        token: token,
        api_dc: data["dc"]
      )
      if api_key.save
        OpenStruct.new(success: true, user: user)
      else
        user.destroy
        OpenStruct.new(success: false, error: api_key.errors.full_messages.first)
      end
    else
      OpenStruct.new(success: false, error: user.errors.full_messages.first)
    end
  rescue => e
    OpenStruct.new(success: false, error: e.message)
  end
  
  def self.integrate_user_from_oauth(user, data, token)
    raise "Invalid MailChimp data" unless data["user_id"].present?
    
    api_key = user.api_keys.where(platform: 'mailchimp', account_id: data["user_id"]).first_or_initialize
    api_key.api_dc = data["dc"]
    api_key.token = token
    
    if api_key.save
      OpenStruct.new(success: true)
    else
      OpenStruct.new(success: false, error: api_key.errors.full_messages.first)
    end
  rescue => e
    OpenStruct.new(success: false, error: e.message)
  end
  
end