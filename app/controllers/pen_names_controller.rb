class PenNamesController < ApplicationController
  
  before_action :sign_in_via_auth_token_param
  before_action :require_current_member_user
  before_action :redirect_prohibited_users
  before_action :withFlash_component, only: [:index]
  
  def index
    @pen_names = PenName.users_pen_names_includes_books_json(current_member_user)
    @pen_name_requests = current_member_user.pen_name_requests.unanswered.includes(:pen_name, :pen_name_owner).as_json(
      include: []#:pen_name, :pen_name_owner]
    )
    @pen_name_groups = current_member_user.pen_names.where.not(group_status: nil).includes(:users).as_json(
      include: { :users => { only: [:email, :id], methods: [:full_name, :name_fallback_email] } }
    )
    render :index
  end
  
  def sharing
    return index()
  end
  
  def request_access
    @pen_name = PenName.find_by_id(params[:id])
    if @pen_name.nil?
      render_404
    elsif @pen_name.users.include?(current_member_user)
      flash[:error] = "This request is invalid because you already have access to this name"
      return redirect_to "/pen_names"
    else
      pnr = PenNameRequest.where(pen_name_id: @pen_name.id, requestor_id: current_member_user.id, owner_decided_at: nil).first_or_create!
      flash[:success] = "A request to use the pen name '#{@pen_name.author_name}' has #{" already" if pnr.already_sent?}been sent to the owner.  You will receive an email when the owner accepts or declines your request."
      return redirect_to "/pen_names"
    end
  end
  
  def grant_request
    @pen_name_request = current_member_user.pen_name_requests.find_by_id(params[:id])
    if @pen_name_request.nil?
      render_404
    elsif @pen_name_request.owner_decided_at?
      flash[:error] = "You have already chosen to #{@pen_name_request.owner_decision} this request"
      return redirect_to "/pen_names"
    else
      @pen_name_request.grant!
      flash[:success] = "You have granted a request from #{@pen_name_request.requestor.email} to use the pen name #{@pen_name_request.pen_name.author_name}.  The requestor has been notified."
      return redirect_to "/pen_names"
    end
  rescue => e
    flash[:error] = e.message +  "[Pen Name Request #{@pen_name_request.id}]"
    return redirect_to "/pen_names"
  end
  
  def deny_request
    @pen_name_request = current_member_user.pen_name_requests.find_by_id(params[:id])
    if @pen_name_request.nil?
      render_404
    elsif @pen_name_request.owner_decided_at?
      flash[:error] = "You have already chosen to #{@pen_name_request.owner_decision} this request"
      return redirect_to "/pen_names"
    else
      @pen_name_request.deny!
      flash[:info] = "You have denied a request from #{@pen_name_request.requestor.email} to use the pen name #{@pen_name_request.pen_name.author_name}.  The requestor has been notified."
      return redirect_to "/pen_names"
    end
  rescue => e
    flash[:error] = e.message +  "[Pen Name Request #{@pen_name_request.id}]"
    return redirect_to "/pen_names"
  end
  
end
