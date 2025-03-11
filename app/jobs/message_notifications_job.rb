class MessageNotificationsJob
  include Sidekiq::Worker

  def perform

    mailboxer_receipts_by_receiver = Mailboxer::Receipt
                         .where(is_read: 0, trashed: 0, deleted: 0, mailbox_type: :inbox, is_delivered: false)
                         .where("created_at > NOW() - interval 30 minute")
                         .includes(:receiver)
                         .group_by(&:receiver)
                    
    mailboxer_receipts_by_receiver.each do |receiver, receipts|

      receipts.group_by(&:conversation).each do |conversation, convo_receipts|

        pen_names = ConversationUserPenName.get_pen_names(conversation, receiver)

        unread_stats = OpenStruct.new
        unread_stats.subject = conversation.subject
        unread_stats.from = pen_names.them.try(:author_name)
        unread_stats.to = pen_names.me.try(:author_name)
        unread_stats.number_unread = convo_receipts.length
        
        receiver.self_with_assistants.select(&:messages_subscribed?).each do |recipient|
          mail = MessageMailer.notify_of_unread_messages(unread_stats, recipient, conversation, receiver.id)
          mail.deliver 
          Email.create({
            user_id: recipient.id,
            mailer: mail.meta_data.mailer_id, 
            email_address: recipient.email
          })
        end
        Mailboxer::Receipt.where(id: convo_receipts.map(&:id)).update_all(is_delivered: true)

      end

    end

  end

end
