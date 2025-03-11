class AssistantPaymentRequestJob
  
  def self.perform(request_id)
    payment_request = AssistantPaymentRequest.find(request_id)
    recipient = payment_request.payer_member
    
    mail = UserMailer.assistant_payment_request(payment_request, recipient)
    mail.deliver
    Email.create({
      user_id: recipient.id,
      mailer: mail.meta_data.mailer_id, 
      email_address: recipient.email
    })
  end
  
  
end
