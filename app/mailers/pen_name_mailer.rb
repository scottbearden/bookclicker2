class PenNameMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
  
  def notify_owner_of_request(pen_name_request, recipient_owner)
    @pen_name = pen_name_request.pen_name
    @requestor = pen_name_request.requestor
    @recipient = recipient_owner
    @pen_name_request = pen_name_request
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Someone has requested to use your pen name '#{@pen_name.author_name}'")
  end
  
  def notify_requestor_of_decision(pen_name_request, recipient_requestor)
    @pen_name = pen_name_request.pen_name
    @owner = pen_name_request.pen_name_owner
    @recipient = recipient_requestor
    @pen_name_request = pen_name_request
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "A decision has been made on your request to use '#{@pen_name.author_name}'")
  end
  
end