class NotifyPenNameOwnerOfRequestJob
  include Sidekiq::Worker
  
  def perform(pen_name_request_id)
    pen_name_request = PenNameRequest.find(pen_name_request_id)
    recipient = pen_name_request.pen_name_owner
    mail = PenNameMailer.notify_owner_of_request(pen_name_request, recipient)
    mail.deliver
    pen_name_request.update!(owner_notified_at: Time.now)
    Email.create!({
      mailer: mail.meta_data.mailer_id, 
      user_id: recipient.id, 
      email_address: recipient.email 
    })
  end
  
end
