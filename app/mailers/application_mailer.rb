class ApplicationMailer < ActionMailer::Base
  default from: SUPPORT_EMAIL
  layout 'mailer'
  include AbstractController::Callbacks
  
  after_action :redirect_for_dev
  after_action :set_mailer_id
  after_action :set_previously_sent_flag

  def redirect_for_dev
    if !Rails.env.production?
      mail.to = [MAILGUN_TEST_EMAIL]
      mail.cc = nil
      mail.bcc = nil
      mail.subject = "[Dev Email #{SecureRandom.hex}] " + mail.subject
    end
  end
  
  def mailer_id
    self.class.to_s + "." + self.action_name
  end
  
  def set_mailer_id
    mail.meta_data.mailer_id = self.mailer_id
  end

  def set_previously_sent_flag
    mail.meta_data.previously_sent = previously_sent?
  end
  
  def previously_sent?
    return false unless @user
    Email.exists?(user_id: @user.id, mailer: self.mailer_id)
  end
  
end
