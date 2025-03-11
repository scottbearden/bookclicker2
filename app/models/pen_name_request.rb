class PenNameRequest < ApplicationRecord
  
  belongs_to :pen_name, -> { unscope(where: :deleted) }
  belongs_to :requestor, class_name: User, foreign_key: :requestor_id
  has_one :pen_name_owner, through: :pen_name, source: :owner
  
  scope :unanswered, -> { where(owner_decision: nil) }
  
  enum owner_decision: { "grant" => "grant", "deny" => "deny" }
  
  after_create :notify_owner
  
  def notify_owner
    NotifyPenNameOwnerOfRequestJob.delay.perform(self.id)
  end
  
  def already_sent?
    created_at && created_at < 4.seconds.ago
  end
  
  def grant!
    UsersPenName.where(user_id: self.requestor_id, pen_name_id: self.pen_name_id).first_or_create!
    if !owner_decided_at?
      if pen_name.group_status.blank?
        pen_name.update_column(:group_status, "closed")
      end
      self.update!(owner_decision: "grant", owner_decided_at: Time.now)
      NotifyPenNameRequestorOfDecisionJob.delay.perform(self.id)
    end
  end
  
  def deny!
    if !owner_decided_at?
      self.update!(owner_decision: "deny", owner_decided_at: Time.now)
      NotifyPenNameRequestorOfDecisionJob.delay.perform(self.id)
    end
  end
  
  def granted?
    grant?
  end
  
  def denied?
    deny?
  end
  
end
