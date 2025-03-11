class AweberAuthController < ApplicationController
  
  
  def index
    oauth = get_aweber_oauth
    req_token = oauth.request_token(oauth_callback: callback_uri)
    session[:aweber_oauth_token_secret] = req_token.secret
    return redirect_to oauth.request_token(:oauth_callback => AWEBER_CALLBACK_URI).authorize_url
  end
  
  def callback
    oauth = get_aweber_oauth
    oauth.request_token = OAuth::RequestToken.from_hash(
      oauth.consumer,
      oauth_token: params[:oauth_token],
      oauth_token_secret: session[:aweber_oauth_token_secret],
    )
    oauth.authorize_with_verifier(params[:oauth_verifier])
    if integrating?
      res = AweberOauthUserManager.integrate_user_from_oauth(current_member_user, oauth)
      if res.success
        flash[:success] = "You've sucessfully integrated with Aweber"
        redirect_to "/integrations"
      else
        flash[:error] = res.error || "There was an error integrating with Aweber"
        redirect_to "/integrations"
      end
    else
      res = AweberOauthUserManager.create_user_from_oauth(oauth)
      if res.success
        flash[:success] = "Welcome"
        login!(res.user)
        redirect_to '/my_lists/selections'
      else
        flash[:error] = res.error || "There was an error signing up with Aweber"
        redirect_to "/create_account"
      end
    end
  rescue => e
    flash[:error] =  e.message
    redirect_to "/"
  end
  
  private
  
  def get_aweber_oauth
    AweberApi.init_oauth
  end
  
  def callback_uri
    AWEBER_CALLBACK_URI + "?role=#{params[:role]}"
  end
  
  def integrating?
    params[:role] == "integrate"
  end
  
end
