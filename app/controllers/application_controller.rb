class ApplicationController < ActionController::Base
  before_action :set_raven_context
  
  protect_from_forgery with: :exception
  helper_method :mobile_device?
  helper_method :current_member_user, :current_assistant_user, :current_assistant_or_member_user

  def report_stripe_unexpected_action_error(stripe_object)
    StripeRequiresActionEvent.create(current_user_id: current_member_user.id, stripe_object_id: stripe_object.id, next_action: stripe_object.next_action)
    Raven.extra_context(stripe_object: stripe_object)
    error = "An error occurred.  Stripe responded with a status of '#{stripe_object.status}'"
    Raven.capture_message(error)
    error
  end
  
  protected
  
  def mobile_device?
    if request.headers['X-UA-Screen'].present?
      request.headers['X-UA-Screen'] == 'small'
    else
      if (request.user_agent =~ /Android/).present? && (request.user_agent =~ /Mobile/).present?
        true
      else
        (request.user_agent =~ /Mobile|iPhone|BlackBerry/).present? && (request.user_agent !~ /iPad/)
      end
    end
  end
  
  def login!(user)
    if user.closed_at?
      flash[:error] = "This account has been closed"
      return false
    else
      cookies[:has_signed_in] = "true"
      session[:session_token] = user.session_token
      return true
    end
  end

  def withFlash_component
    @flash = flash.first.try(:[],1)
    @flash_type = flash.first.try(:[],0)
    flash.clear
  end
  
  def make_modal_wide
    @wide_modal = true
  end
  
  def logout
    @current_member_user = nil
    @current_assistant_user = nil
    session[:session_token] = nil
    cookies[:viewed_integrations_warning] = nil
  end
  
  def current_member_user
    return nil if session[:session_token].nil?
    @current_member_user ||= begin
      user = User.find_by_session_token(session[:session_token])
      return nil if user.nil?
      if user.full_member?
        user
      elsif user.assistant?
        @current_assistant_user = user
        member_user = user.assisted_users.find_by_id(cookies[:assisting_user_id])
      end
    end
  end
  
  def current_assistant_user
    current_member_user.inspect
    @current_assistant_user
  end
  
  def current_assistant_or_member_user
    current_assistant_user || current_member_user
  end
  
  def block_assistant
    if current_assistant_user.present?
      flash[:danger] = "Restricted access"
      return redirect_to "/"
    end
  end
  
  def require_current_member_user
    if !current_member_user
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: ["not authorized"], status: :bad_request }
      end
    end
  end
  
  def require_current_assistant_user
    if !current_assistant_user
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: ["not authorized"], status: :bad_request }
      end
    end
  end
  
  def require_current_assistant_or_member_user
    if !current_assistant_or_member_user
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: ["not authorized"], status: :bad_request }
      end
    end
  end

  def redirect_prohibited_users
    if current_member_user.present? && current_member_user.prohibitive_refund_request_reservation.present?
      if request.path.match(/^\/(dashboard|confirm_promos|reservations)/i)
        return nil
      else
        return redirect_to "/dashboard"
      end
    end
    if current_assistant_or_member_user && !current_assistant_or_member_user.email_verified?
      return redirect_to "/unverified"
    end
  end
  
  def send_current_user_to_landing_page
    if current_assistant_or_member_user.present?
      if current_assistant_or_member_user.assistant?
        return redirect_to "/profile"
      else
        return redirect_to "/dashboard"
      end
    end
  end
  
  def sign_in_via_auth_token_param
    
    if params[:bc_token].present?
      user = User.find_by_session_token(params[:bc_token])
      
      if user.present? and login!(user)
        cookies[:assisting_user_id] = params[:auid].presence
      else
        logout
        return render_422
      end
    end
    
    if !current_member_user.present?
      return redirect_to "/sign_in"
    end
  end
  
  def pagination(scope, req_params, path = nil)
    page = {}
    if scope.current_page > 1
      page["first"] = 1
      page["prev"] = scope.current_page - 1
    end
    if scope.total_pages > scope.current_page
      page["next"] = scope.current_page + 1
      page["last"] = scope.total_pages
    end
    links = {}
    page.each do |rel, page_no|
      links[rel] = page_no
    end
    links
  end
  
  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", status: :not_found }
      format.json { render json: { error: "Item not found", message: "Item not found" }, status: :not_found }
    end
  end

  def render_422
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/422.html", status: :bad_request }
      format.json { render json: { error: "Could not process request", message: "Could not process request" }, status: :bad_request }
    end
  end
  
  def set_raven_context
    Raven.user_context(
      session_token_first_8: session[:session_token].try(:first, 8),
      session_token_last_2: session[:session_token].try(:last, 2)
    )
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
  
end
