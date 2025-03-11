class Api::ConversationsController < Api::BaseController

  include ConversationsConcern
  before_action :require_current_member_user
  before_action :get_mailbox
  before_action :check_current_member_user_in_conversation, except: [:create]

  def reply
    if message_params[:message_body].blank?
      return render json: {
        success: false,
        error: "Empty message provided"
      }, status: :unprocessable_entity
    else 
      new_receipt = current_member_user.reply_to_conversation(conversation, message_params[:message_body])
      if new_receipt.persisted?
        receipts = @mailbox.receipts_for(conversation)
        render json: {
          success: true,
          receipts: receipts.as_json(include: ConversationsConcern::MESSAGE_JSON)
        }, status: :ok
        receipts.mark_as_read
        return
      else 
        return render json: {
          success: false,
          error: "Message could not be sent"
        }, status: :unprocessable_entity
      end
    end
    
  end

  def show
    receipts = @mailbox.receipts_for(conversation)
    receipts.mark_as_read
    render json: {
      success: true,
      receipts: receipts.as_json(include: ConversationsConcern::MESSAGE_JSON)
    }, status: :ok
  end

  def create
    @from_pen_name = PenName.find_by_id(params[:from_pen_name_id])
    @to_pen_name = PenName.find_by_id(params[:to_pen_name_id])
    @to_user = User.find_by_id(params[:to_user_id])

    if !current_member_user.pen_names_used.include?(@from_pen_name)
      return render json: {
        success: false,
        error: "Invalid 'From' pen name"
      }, status: :unprocessable_entity
    elsif !@to_pen_name || !@to_user
      return render json: {
        success: false,
        error: "Recipient not found"
      }, status: :unprocessable_entity
    elsif params[:message_body].blank?
      return render json: {
        success: false,
        error: "Message body can't be blank"
      }, status: :unprocessable_entity
    end

    receipt = nil
    first_inbox_receipt = nil
    ActiveRecord::Base.transaction do
      receipt = current_member_user.send_message(@to_user, params[:message_body], params[:message_subject])
      first_inbox_receipt = receipt.message.receipts.find { |rec| rec.mailbox_type == "inbox" }
      ConversationUserPenName.create_from_receipt!(first_inbox_receipt, @from_pen_name, @to_pen_name)
    end

    if !receipt || !receipt.persisted?
      return render json: {
        success: false,
        error: "Message did not save"
      }, status: :unprocessable_entity
    else
      return render json: {
        success: true,
        conversation: receipt.conversation.as_json,
        link_to_conversation: conversation_url(receipt.conversation)
      }, status: :ok
    end

  end

  def move_to_trash
    conversation.move_to_trash current_member_user
    conversation.check_if_trashed_for(current_member_user)
    return render json: {
      success: true,
      conversation: conversation.as_json(methods: [:is_trashed])
    }
  end

  def untrash
    conversation.untrash current_member_user
    conversation.check_if_trashed_for(current_member_user)
    return render json: {
      success: true,
      conversation: conversation.as_json(methods: [:is_trashed])
    }
  end

  def message_params
    params.permit(:message_body)
  end


end