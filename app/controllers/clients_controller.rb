class ClientsController < ApplicationController
  
  
  before_filter :sign_assistant_in_via_auth_token_param
  before_filter :require_current_assistant_user
  
  def index
    @client_connections = current_assistant_user.assistants_users
                          .includes({user: :pen_names_used}, :assistant_payment_requests)
                          .as_json(UsersAssistant.clients_page_json)
  end
  
  def sign_assistant_in_via_auth_token_param
    if params[:bc_token].present?
      user = User.find_by_session_token(params[:bc_token])
      if user.present? and login!(user)
        cookies[:assisting_user_id] = params[:auid].presence
      else
        logout
        return render_422
      end
    end
    if !current_assistant_user.present?
      return redirect_to "/sign_in"
    end
  end
  
end