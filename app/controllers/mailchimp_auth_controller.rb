class MailchimpAuthController < ApplicationController
  
  def index
    logout unless integrating?
    redirect_to MailchimpApi.authorize_url(redirect_uri: redirect_uri) 
  end
  
  def callback
    access_token = MailchimpApi.get_access_token(code: params[:code], redirect_uri: redirect_uri)
    session_metadata = MailchimpApi.new(token: access_token).get_metadata
    
    if integrating?
      res = MailchimpOauthUserManager.integrate_user_from_oauth(
              current_member_user,
              session_metadata,
              access_token)
              
      if res.success
        flash[:success] = "You've sucessfully integrated with MailChimp"
        redirect_to "/integrations"
      else
        flash[:error] = res.error || "There was an error integrating with Mailchimp"
        redirect_to "/integrations"
      end
    else
      res = MailchimpOauthUserManager.create_user_from_oauth(
               session_metadata,
               access_token)
      if res.success
        flash[:success] = "Welcome to Bookclicker"
        res.user.verify_email!
        login!(res.user)
        redirect_to '/profile?welcome=true'
      else
        flash[:error] = res.error
        redirect_to "/create_account"
      end
    end
  end
  
  private
  
  def redirect_uri
    MAILCHIMP_REDIRECT_URI + "?role=#{params[:role]}"
  end
  
  def signing_in?
    params[:role] == "sign_in"
  end
  
  def integrating?
    params[:role] == "integrate"
  end
    
end