module ConversationsConcern
  extend ActiveSupport::Concern

  MESSAGE_JSON = {
    message: {
      only: [:created_at, :id, :subject, :body],
      include: {
        sender: {
          only: [:id]
        }
      }
    }
  }

  def check_current_member_user_in_conversation
  	if !conversation
  	  return render_404
    end

    if !conversation.is_participant?(current_member_user)
      return render_422
    end

    conversation.check_if_trashed_for(current_member_user)
  end

  def get_mailbox
    @mailbox ||= current_member_user.mailbox
  end

  def get_box
    if params[:box].blank? or !["inbox","sentbox","trash"].include?params[:box]
      params[:box] = 'inbox'
    end

    @box = params[:box]
  end

  def conversation
  	@conversation ||= Mailboxer::Conversation.find_by_id(params[:id])
  end


end