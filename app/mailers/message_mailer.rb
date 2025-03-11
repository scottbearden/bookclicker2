class MessageMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  MESSAGES_FROM_EMAIL = "messages@bookclicker.com"
  
  def notify_of_unread_messages(message_stats, recipient, conversation, member_user_id)
    @view_conversation_link = SITE_URL + "/conversations/#{conversation.id}?bc_token=#{recipient.session_token}&auid=#{member_user_id}"
    @message_stats = message_stats
    @recipient = recipient
    @link_to_view
    mail(from: MESSAGES_FROM_EMAIL, to: [@recipient.email], subject: (message_stats.subject.presence || "New message on Bookclicker"))
  end

  
end