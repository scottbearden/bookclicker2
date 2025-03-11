class Api::IntegrationsController < Api::BaseController
  
  before_action :require_current_member_user
  before_action :block_assistant
  
  def index
    #deprecated
  end
  
  def show
    @api_key = current_member_user.api_keys.find_by_id(params[:id])
    if @api_key.present?
      successful_save_response
    else
      render_404
    end
  end
  
  def destroy
    @api_key = current_member_user.api_keys.find_by_id(params[:id])
    @api_key_status = @api_key.init_api.status
    
    if @api_key.affected_lists.present? && @api_key_status == "Good"
      @api_key.deactivate_mailing_lists
      render json: { 
        success: true, 
        destroyMessage: nil,
        api_key: @api_key.as_json(only: [:id, :platform, :updated_at], 
        methods: [:platform_nice]), 
        status: @api_key_status,
        affected_lists: Reservation.settle_associated_reservations_json(@api_key.affected_lists),
        affected_books: []
      }, status: :ok
    elsif @api_key.destroy
      render json: { 
        success: true, 
        destroyMessage: "API key deleted. We have successfully removed all affected lists from the marketplace.", 
        api_key: @api_key.as_json(only: [:platform, :updated_at], 
        methods: [:platform_nice]), 
        status: nil,
        affected_lists: [],
        affected_books: []
      }, status: :ok
    else
      render json: { success: false, errorMessage: @api_key.errors.full_messages.first, status: "Bad"}, status: :bad_request
    end
  end
  
  def update  
    @api_key = current_member_user.api_keys.find_by_id(params[:id])
    if @api_key.present?
      if @api_key.update(key: params[:key])
        successful_save_response
      else
        render json: { success: false, errorMessage: @api_key.errors.full_messages.first, status: "Bad"}, status: :bad_request
      end
    else
      render_404
    end
  rescue => e
    render json: { success: false, errorMessage: e.message, status: "Bad"}, status: :bad_request
  end
  
  def create
    @api_key = current_member_user.api_keys.new(api_key_params)
    if @api_key.save
      successful_save_response
    else
      render json: { success: false, errorMessage: @api_key.errors.full_messages.first, status: "Bad"}, status: :bad_request
    end
  rescue => e
    render json: { success: false, errorMessage: e.message, status: "Bad"}, status: :bad_request
  end
  
  
  private
  
  def api_key_params
    params.permit(:platform, :key)
  end
  
  def successful_save_response
    render json: { success: true, api_key: api_key_json, status: @api_key.init_api.status}, status: :ok
  end
  
  def api_key_json
    @api_key.as_json(
              only: [:id, :updated_at, :platform],
              methods: [:key, :platform_nice] )
  end
  
end
