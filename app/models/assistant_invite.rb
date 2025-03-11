class AssistantInvite < ApplicationRecord
  
  belongs_to :member_user, -> { full_member }, class_name: 'User', foreign_key: :member_user_id
  belongs_to :assistant_user, -> { assistant }, class_name: 'User', foreign_key: :assistant_user_id
  
  validates :invitee_email, :pen_name, presence: true
  validates_format_of :invitee_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  
  validate :unique_invitation, on: :create
  
  validate :under_invite_max, on: :create
  
  validate :user_doesnt_exist, on: :create
  
  after_create :send_invite
  
  def send_invite
    InviteAssistantJob.perform_async(self.id)
  end
  
  def unique_invitation
    if AssistantInvite.where(member_user_id: member_user_id, invitee_email: invitee_email).present?
      errors.add(:base, "You have already sent an invitation to this email")
    end
  end
  
  def under_invite_max
    if AssistantInvite.where(member_user_id: member_user_id).count > 25
      errors.add(:base, "You have sent too many invitations")
    end
  end
  
  def user_doesnt_exist
    if User.exists?(email: invitee_email)
      errors.add(:base, "A user with this email already exists.  Try using the assistant select tool to find and select this user.")
    end
  end
  
  def accept_invite_link
    SITE_URL + "/assistant_invites/#{id}?digest=#{invitee_email_digest}"
  end
  
  def invitee_email_digest
    Digest::MD5.hexdigest(self.invitee_email.downcase)
  end
  
end