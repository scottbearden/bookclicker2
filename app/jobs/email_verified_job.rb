class EmailVerifiedJob
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    mail = UserMailer.launcher_email_verified(user)
    
    if !mail.meta_data.previously_sent
      mail.deliver
      Email.create!({
        mailer: mail.meta_data.mailer_id, 
        user_id: user.id, 
        email_address: user.email 
      })
    end
    
    if Rails.env.production?
      MailingSegmentManager.new.add(user)
    end
  end
  
end
