class ConversationsController < ApplicationController
  

  include ConversationsConcern
  before_filter :sign_in_via_auth_token_param, only: [:index, :show]
  before_filter :require_current_member_user
  before_filter :get_mailbox, :get_box
  before_filter :check_current_member_user_in_conversation, :except => [:index]

  def index
    if @box.eql? "inbox"
      @conversations = @mailbox.inbox.page(params[:page]).per(100)
    elsif @box.eql? "sentbox"
      @conversations = @mailbox.sentbox.page(params[:page]).per(100)
    else
      @conversations = @mailbox.trash.page(params[:page]).per(100)
    end

    respond_to do |format|
      format.html { render @conversations if request.xhr? }
    end
  end

  def show
    @receipts = @mailbox.receipts_for(@conversation)
    @interlocutor = @conversation.participants.find { |r| r.id != current_member_user.id }
    @receiptsJson = @receipts.as_json(include: ConversationsConcern::MESSAGE_JSON)
    render :action => :show
    @receipts.mark_as_read
  end


end