class EmailVerificationJob
  
  def self.perform(user_id, previous_email = nil)
    sleep(2.0)
    user = User.find(user_id)
    return nil if Email.banned?(user.email)
    mail = UserMailer.launcher_email_verification(user)
    mail.deliver
    Email.create!({
      mailer: mail.meta_data.mailer_id, 
      user_id: user.id, 
      email_address: user.email 
    })
    if Rails.env.production? && previous_email.present? && !Email.banned?(previous_email)
      MailingSegmentManager.new.remove(user, previous_email)
    end
  end
  
end
