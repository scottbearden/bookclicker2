class ConversationUserPenName < ApplicationRecord

  belongs_to :conversation, class_name: 'Mailboxer::Conversation'
  belongs_to :receipt, class_name: 'Mailboxer::Receipt'

  validates_uniqueness_of :conversation_id
  validate :receipt_is_of_conversation

  default_scope { order(created_at: :desc) }


  def self.get_pen_names(conversation, me)

    record = self.find_by(conversation: conversation)
    return OpenStruct.new unless record
    them = nil

    if record.receipt.receiver == me
      them = record.receipt.message.sender
      me.conversation_pen_name = PenName.unscoped.find(record.receipt_pen_name_id)
      them.conversation_pen_name = PenName.unscoped.find(record.sender_pen_name_id)
    elsif record.receipt.message.sender == me
      them = record.receipt.receiver
      me.conversation_pen_name = PenName.unscoped.find(record.sender_pen_name_id)
      them.conversation_pen_name = PenName.unscoped.find(record.receipt_pen_name_id)
    else
      raise "User is participant in conversation"
    end

    return OpenStruct.new(
      me: me.conversation_pen_name,
      them: them.conversation_pen_name
    )
  rescue
    OpenStruct.new
  end


  def self.create_from_receipt!(receipt, sender_pen_name, receiver_pen_name)
    self.create!(
      receipt_id: receipt.id,
      receipt_pen_name_id: receiver_pen_name.id,
      sender_pen_name_id: sender_pen_name.id,
      conversation_id: receipt.message.conversation_id,
    )
  end

  def receipt_is_of_conversation
    if !receipt.conversation || receipt.conversation.id != self.conversation_id
      errors.add(:receipt, "must belong to conversation")
    end
  end


end
