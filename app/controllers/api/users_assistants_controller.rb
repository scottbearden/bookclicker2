class Api::UsersAssistantsController < Api::BaseController
  
  before_action :block_assistant
  
  def create
    users_assistant = current_member_user.users_assistants.new(assistant_id: params[:assistant_id])
    if users_assistant.save
      render json: { message: "Assistant added successfully", users_assistants: current_member_user.users_assistants_ordered_json }, status: :ok
    else
      render json: { success: false, message: users_assistant.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def update
    users_assistant = current_member_user.users_assistants.find_by_id(params[:id])
    if users_assistant.present?
      if users_assistant.has_interaction?
        render json: { success: false, message: "You may not change this assistant" }, status: :bad_request
      elsif users_assistant.update(assistant_id: params[:assistant_id])
        render json: { message: "Assistant updated", users_assistants: current_member_user.users_assistants_ordered_json }, status: :ok
      else
        render json: { success: false, message: users_assistant.errors.full_messages.first }, status: :bad_request
      end
    else
      render_404
    end
  end
  
  def destroy
    users_assistant = current_member_user.users_assistants.find_by_id(params[:id])
    if users_assistant.present?
      if users_assistant.has_interaction?
        render json: { success: false, message: "You may not delete this assistant" }, status: :bad_request
      elsif users_assistant.destroy
        render json: { message: "Assistant deleted", users_assistants: current_member_user.users_assistants_ordered_json }, status: :ok
      else
        render json: { success: false, message: users_assistant.errors.full_messages.first }, status: :bad_request
      end
    else
      render_404
    end
  end
  
  def invite
    invite = current_member_user.assistant_invites.new(invite_assistant_params)
    if invite.save
      render json: { success: true }, status: :ok
    else
      render json: { success: false, message: invite.errors.full_messages.first }, status: :bad_request
    end
  end
  
  private
  
  def invite_assistant_params
    params.permit(:invitee_email, :pen_name)
  end
  
end
