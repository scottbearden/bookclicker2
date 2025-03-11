class InviteAssistantJob
  include Sidekiq::Worker
  
  def perform(invite_id)
    invite = AssistantInvite.find(invite_id)
    
    return nil if Email.banned?(invite.invitee_email)
    
    mail = UserMailer.invite_assistant(invite)
    mail.deliver
    Email.create({
      user_id: -1,
      email_address: invite.invitee_email,
      mailer: mail.meta_data.mailer_id, 
    })
    
  end
  
end
