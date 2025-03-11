class Api::PenNamesController < Api::BaseController
  
  before_action :require_current_member_user
    
  def index
    render json: {
      pen_names: PenName.users_pen_names_includes_books_json(current_member_user),
      pen_name_requests: current_member_user.pen_name_requests.unanswered.includes(:pen_name, :pen_name_owner).as_json(
        include: []#:pen_name, :pen_name_owner]
      ),
      pen_name_groups: current_member_user.pen_names.where.not(group_status: nil).includes(:users).as_json(
        include: { :users => { only: [:email, :id], methods: [:full_name, :name_fallback_email] } }
      )
    }, status: :ok
  end
  
  def list_for_buyer
    render json: {
      pen_names: current_member_user.pen_names_used.not_promo_service.as_json
    }, status: :ok
  end
  
  def create
    pen_name = current_member_user.pen_names.new(pen_name_params)
    
    if !pen_name.promo_service_only? && pen_name.identical_pen_name.present?
      ipn = pen_name.identical_pen_name
      if ipn.users.include?(current_member_user)
        render json: { message: "You have already added this pen name" }, status: :bad_request
      elsif ipn.open?
        UsersPenName.where(user_id: current_member_user.id, pen_name_id: ipn.id).first_or_create!
        render json: { message: "You have successfully added this pen name.  Note that you have joined a group pen name." }, status: :accepted
      elsif ipn.closed?
        pnr = PenNameRequest.where(pen_name_id: ipn.id, requestor_id: current_member_user.id, owner_decided_at: nil).first_or_create!
        render json: { message: "You have attempted to join the closed pen name '#{ipn.author_name}'.  A request to join has #{"already " if pnr.already_sent?}been sent to the owner of this name.  You will receive an email when the owner accepts or declines your request.  If this is your pen name, you may open a dispute by emailing us at <a href='mailto:disputes@bookclicker.com' target='_top'>disputes@bookclicker.com</a>." }, status: :unauthorized
      else
        render json: { message: non_shared_options_prompt(ipn).html_safe }, status: :unauthorized
      end
    elsif pen_name.save
      UsersPenName.where(user_id: current_member_user.id, pen_name_id: pen_name.id).first_or_create!
      render json: { message: nil }, status: :created
    else
      render json: { message: pen_name.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def update
    #TODO same ipn logic as in create
    pen_name = current_member_user.pen_names.find_by_id(params[:id])
    if pen_name.present?
      if pen_name.update(pen_name_params)
        render json: { success: true }, status: :ok
      else
        render json: { success: false, message: pen_name.errors.full_messages.first }, status: :bad_request
      end
    else
      render_404
    end  
  end

  def destroy
    pen_name = current_member_user.pen_names.find_by_id(params[:id])
    if pen_name.update(deleted: true)
      flash[:success] = "Pen name '#{pen_name[:author_name]}' successfully deleted"
      render json: { success: true }, status: :ok
    else
      render json: { success: false, message: pen_name.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def pen_name_params
    params.permit(:author_profile_url, :author_name, :author_image, :verified, :promo_service_only, :group_status)
  end
  
  private
  
  def non_shared_options_prompt(existing_pen_name)
    result = "This pen name (#{existing_pen_name.author_name}) has already been claimed by another user.  "
    result += "If this is a group pen name, <a href='/pen_names/#{existing_pen_name.id}/request_access'>request access</a>.  "
    result += "If this is your pen name, open a dispute by emailing us at <a href='mailto:disputes@bookclicker.com' target='_top'>disputes@bookclicker.com</a>"
    result
  end
  
end
