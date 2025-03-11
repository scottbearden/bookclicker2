class UserMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
  
  def launcher_email_verification(user)
    @user = user
    @has_received_this_email = previously_sent?
    mail(from: SUPPORT_EMAIL, to: [@user.email], subject: "Bookclicker Account Verification")
  end
  
  def launcher_email_verified(user)
    @user = user
    mail(from: SUPPORT_EMAIL, to: [@user.email], subject: "Welcome to Bookclicker!")
  end
  
  def reset_password(user, reset_password_link)
    @user = user
    @reset_password_link = reset_password_link
    mail(from: SUPPORT_EMAIL, to: [@user.email], subject: "Reset your password")
  end
  
  def invite_assistant(invite)
    @invite = invite
    mail(from: SUPPORT_EMAIL, to: [@invite.invitee_email], subject: "You've received an invitation to join Bookclicker")
  end
  
  def assistant_payment_request(payment_request, recipient)
    @payment_request = payment_request
    @assistant = payment_request.assistant
    @recipient = recipient
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your assistant would like to start a payment plan. [#{payment_request.id}]")
  end
  
  def notify_assistant_of_request_accept(payment_request, recipient, member)
    @payment_request = payment_request
    @recipient = recipient
    @member = member
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your payment request has been accepted! [#{payment_request.id}]")
  end
  
  def notify_assistant_of_request_decline(payment_request, recipient, member)
    @payment_request = payment_request
    @recipient = recipient
    @member = member
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your payment request has been declined [#{payment_request.id}]")
  end
  
  def notify_member_that_assistant_has_deleted_account(recipient, member, assistant_name, assistant_email)
    @recipient = recipient
    @member = member
    @assistant_name = assistant_name
    @assistant_email = assistant_email
    mail(from: SUPPORT_EMAIL, to: [@recipient.email], subject: "Your assistant has deleted their account")
  end
  
end