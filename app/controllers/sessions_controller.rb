class SessionsController < ApplicationController
  
  def new
    logout
    render :new
  end
  
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password]) and login!(user)
      send_current_user_to_landing_page
    else
      flash[:warning] = "Those login credentials are incorrect"
      redirect_to login_path
    end
  end
  
  def destroy
    logout
    redirect_to root_path
  end
  
end