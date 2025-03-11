class Api::UserEventsController < Api::BaseController
  
  before_action :require_current_assistant_or_member_user
  
  def create
    if current_assistant_or_member_user.user_events.create(event_params)
      render json: {}, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end
  
  
  def event_params
    params.permit(:event, :event_detail)
  end
  
end