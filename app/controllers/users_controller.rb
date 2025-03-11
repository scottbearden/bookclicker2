class UsersController < ApplicationController
  
  before_action :require_current_assistant_or_member_user, only: [:update_password, :unverified]
  before_action :require_current_assistant_user, only: [:destroy_assistant]
  
  before_action :handle_reset_password_token, only: [:reset_password_page, :reset_password_submit]
  
  def new
    if current_assistant_or_member_user.present?
      redirect_to root_path
    else
      render :new
    end
  end
  
  def create
    user = User.new(user_params)
    if user.save
      login!(user)
      flash[:success] = "Welcome to Bookclicker"
      redirect_to "/profile?welcome=true"
    else
      flash[:error] = user.errors.full_messages.first
      redirect_back(fallback_location: root_path)
    end
  end
  
  def update_password
    if current_assistant_or_member_user.update(user_password_params)
      flash[:success] = "Your password has been updated successfully"
    else
      flash[:error] = current_assistant_or_member_user.errors.full_messages.first
    end
    redirect_to "/profile"
  end
  
  def verify_email
    logout
    user = User.find_by_session_token(params[:ve_token]) if params[:ve_token].present?
    
    if !user.present?
      flash.now[:error] = "Would could not locate your account"
      return render_404
    elsif !user.email_verified?
      if params['digest'].present? && user.email_digest == params['digest']
        user.verify_email!
        login!(user)
        flash[:success] = "Thank you for verifying your email"
      else
        flash[:warning] = "This verification link does not correspond to your current email address"
      end
    else
      login!(user)
      flash[:warning] = "Your email has already been verified"
    end
    redirect_to "/"
  end

  def unverified
    if current_assistant_or_member_user.email_verified?
      flash.clear
      return redirect_to '/dashboard'
    end
    @user = current_assistant_or_member_user
    flash.now[:danger] = "You must have a verified email address to use Bookclicker"
  end
  
  def reset_password_request
  end
  
  def reset_password_request_submit
    flash.clear
    if user = User.find_by_email(params[:email])
      ResetPasswordEmailJob.perform_async(user.id)
      flash.now[:success] = "An email to reset your password is on its way"
      return render :reset_password_request_submit
    else
      flash.now[:error] = "We could not locate a user by that email address"
      return render :reset_password_request
    end
  end
  
  def reset_password_page
    @token = params['token']
    @user = PasswordToken.find_by_token(params['token']).user.as_json(only: [:email])
    render :reset_password
  end
  
  def reset_password_submit
    flash.clear
    @user = PasswordToken.find_by_token(params['token']).user
    if @user.update(password: params['password'], password_confirmation: params['password_confirmation'])
      flash[:success] = "Your password has been updated successfully"
      @user.reset_session_token!
      login!(@user)
      return redirect_to ('/dashboard')
    else
      flash[:error] = @user.errors.full_messages.first
      redirect_back(fallback_location: root_path)
    end
  end
  
  def assist
    cookies[:assisting_user_id] = params[:auid]
    if current_assistant_user.present? && current_member_user.present? && current_member_user.id == params[:auid].to_i
      flash[:success] = "You are now assiting " + current_member_user.assisting_display_name
      redirect_to "/dashboard"
    else
      flash[:error] = "There was an error with your request"
      redirect_back(fallback_location: root_path)
    end
  end
  
  def destroy_assistant
    current_assistant_user.destroy_assistant
    flash[:notice] = "Your account has been deleted"
    logout
    redirect_to "/"
  rescue => e
    flash[:error] = "Error: #{e.message}"
    redirect_to "/profile"
  end
  
  private
  
  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :role)
  end
  
  def book_params
    params.fetch(:book, {}).permit(:title, :author, :blurb)
  end
  
  def user_password_params
    params.fetch(:user, {}).permit(:password, :password_confirmation)
  end

  
  def handle_reset_password_token
    res = PasswordToken.valid?(params['token'])
    if !res.valid
      flash[:error] = res.message || 'Invalid request'
      return redirect_to "/login"
    end
  end
  
  
end