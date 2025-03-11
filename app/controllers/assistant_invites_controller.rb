class AssistantInvitesController < ApplicationController
  
  def show #creates assistant from link
    
    def on_asst_invite_accept_error
      redirect_to "/create_account?provider=assistant"
    end
    
    if invite.present? && params['digest'] == invite.invitee_email_digest
      if invite.assistant_created_at?
        flash[:error] = "This invitation link has already been used."
        return on_asst_invite_accept_error
      else
        logout
        assistant = User.new({
          skip_email_verification: true,
          role: 'assistant', 
          email: invite.invitee_email, 
          password: SecureRandom::urlsafe_base64(8)
        })
        if assistant.save
          assistant.verify_email!
          invite.update(assistant_created_at: Time.now, assistant_user_id: assistant.id)
          login!(assistant)
          UsersAssistant.create(user_id: invite.member_user_id, assistant_id: assistant.id)
          cookies[:assisting_user_id] = invite.member_user_id
          flash[:success] = "Welcome to Bookclicker.  Please add your name and set a password"
          return redirect_to "/profile?welcome=true"
        else
          flash[:error] = assistant.errors.full_messages.first
          return on_asst_invite_accept_error
        end
      end
    else
      flash[:error] = "This invitation link is invalid."
      return redirect_to on_asst_invite_accept_error
    end
  rescue => e
    flash[:error] = e.message
    return redirect_to "/create_account?provider=assistant"
  end
  
  
  def invite
    @invite ||= AssistantInvite.find_by_id(params[:id])
  end
  
end