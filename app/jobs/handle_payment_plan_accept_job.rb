class HandlePaymentPlanAcceptJob
  include Sidekiq::Worker
  
  def perform(pay_request_id)
    pay_request = AssistantPaymentRequest.find(pay_request_id)
    recipient = pay_request.users_assistant.assistant
    member = pay_request.users_assistant.user
    
    mail = UserMailer.notify_assistant_of_request_accept(pay_request, recipient, member)
    mail.deliver
    Email.create!({
      user_id: recipient.id,
      email_address: recipient.email,
      mailer: mail.meta_data.mailer_id
    })
  end
  
end
