class AweberOauthUserManager
  
  def self.create_user_from_oauth(oauth)
    aweber_api = AweberApi.new(oauth: oauth)
    raise "Unable to connect to Aweber Api" unless aweber_api.account_id.present?
    
    user = User.new(
      email: "aweber-#{aweber_api.account_id}@bookclicker.com",
      skip_email_verification: true,
      password: aweber_api.account_id.to_s,
      role: 'full_member'
    )
    
    if user.save
      api_key = user.api_keys.new(
        platform: 'aweber',
        account_id: aweber_api.account_id,
        token: oauth.access_token.token, 
        secret: oauth.access_token.secret
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
  
  def self.integrate_user_from_oauth(user, oauth)
    aweber_api = AweberApi.new(oauth: oauth)
    api_key = user.api_keys.where(platform: 'aweber', account_id: aweber_api.account_id).first_or_initialize
    api_key.token = oauth.access_token.token
    api_key.secret = oauth.access_token.secret
    
    if api_key.save
      OpenStruct.new(success: true)
    else
      OpenStruct.new(success: false, error: api_key.errors.full_messages.first)
    end
  rescue => e
    OpenStruct.new(success: false, error: e.message)
  end
  
end
  
  