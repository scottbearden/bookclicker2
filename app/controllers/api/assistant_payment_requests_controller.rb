class Api::AssistantPaymentRequestsController < Api::BaseController
  
  
  
  before_filter :require_current_assistant_user, only: [:create]
  
  
  before_filter :sign_in_via_auth_token_param, only: [:pay_and_accept]
  before_filter :require_current_member_user, only: [:pay_and_accept, :accept, :decline, :terminate]
  
  def create
    @as_assistant = true
    if users_assistant.present?
      if users_assistant.can_add_request?
        payment_request = users_assistant.assistant_payment_requests.new(payment_request_params)
        if payment_request.save
          render json: { success: true, connection: connection_json }, status: :ok
        else
          render json: { success: false, message: payment_request.errors.full_messages.first }, status: :bad_request
        end
      else
        render json: { success: false, message: 'You cannot make a payment request to this user'}, status: :bad_request
      end
    else
      render_404
    end
  end
  
  def decline
    @as_assistant = false
    if users_assistant.present?
      payment_request = users_assistant.assistant_payment_requests.find_by_id(params[:id])
      if payment_request.present?
        if payment_request.unanswered?
          payment_request.decline!
          return render json: { 
            success: true, 
            payment_request: payment_request.as_ui_json 
          }, status: :ok
        else
          return render json: { 
            success: false, 
            message: "This request has already been #{payment_request.accepted? ? "accepted" : "declined"}", 
            payment_request: payment_request.as_ui_json 
          }, status: :bad_request
        end
      end
    end
    render_404
  end
  
  def terminate
    @as_assistant = false
    if users_assistant.present?
      payment_request = users_assistant.assistant_payment_requests.find_by_id(params[:id])
      if payment_request.present?
        if payment_request.can_terminate_subscription?
          res = payment_request.terminate_active_subscription
          if res.success
            return render json: { 
              success: true, 
              payment_request: payment_request.as_ui_json 
            }, status: :ok
          else
            return render json: { 
              success: true, 
              message: "We were unable to end this subscription. Please use your Stripe dashboard to cancel payment. Error - #{res.failure_message}",
              payment_request: payment_request.as_ui_json 
            }, status: :bad_request
          end
        else
          return render json: { 
            success: false, 
            message: "We were unable to end this subscription. Please use your Stripe dashboard to cancel payment.", 
            payment_request: payment_request.as_ui_json 
          }, status: :bad_request
        end
      end
    end
    render_404
  end
  
  def accept
    #TODO
  end
  
  def pay_and_accept
    @as_assistant = false
    if users_assistant.present?
      payment_request = users_assistant.assistant_payment_requests.find_by_id(params[:id])
      if payment_request.present?
        if payment_request.cancelled?
          flash[:error] == "This request has already been cancelled"
          return redirect_to :back
        else
          #@users_assistant already retrieved
          @payment_request = payment_request.as_ui_json
          @assistant = users_assistant.assistant.as_json(methods: [:full_name_or_email])
          return render "assistant_payment_requests/pay_and_accept"
        end
      end
    end
    render_404
  end
  
  private
  
  def payment_request_params
    params.permit(:pay_amount)
  end
  
  def users_assistant
    if @as_assistant
      @users_assistant ||= current_assistant_user.assistants_users.find_by_id(params[:users_assistant_id])
    else
      @users_assistant ||= current_member_user.users_assistants.find_by_id(params[:users_assistant_id])
    end
  end
  
  def connection_json
    @users_assistant = nil
    users_assistant.as_json(UsersAssistant.clients_page_json)
  end
  
end