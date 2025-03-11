class NotifyPenNameRequestorOfDecisionJob
  include Sidekiq::Worker
  
  def perform(pen_name_request_id)
    pen_name_request = PenNameRequest.find(pen_name_request_id)
    recipient = pen_name_request.requestor
    mail = PenNameMailer.notify_requestor_of_decision(pen_name_request, recipient)
    mail.deliver
    Email.create!({
      mailer: mail.meta_data.mailer_id, 
      user_id: recipient.id, 
      email_address: recipient.email 
    })
  end
  
end
