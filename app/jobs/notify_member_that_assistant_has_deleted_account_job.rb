class NotifyMemberThatAssistantHasDeletedAccountJob
  include Sidekiq::Worker
  
  def perform(member_id, assistant_name, assistant_email)
    
    recipient = member = User.find(member_id)
    
    mail = UserMailer.notify_member_that_assistant_has_deleted_account(recipient, member, assistant_name, assistant_email)
    mail.deliver
    
    Email.create({
      user_id: recipient.id,
      email_address: recipient.email,
      mailer: mail.meta_data.mailer_id, 
    })
    
  end
  
  
end
