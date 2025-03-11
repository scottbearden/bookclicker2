class ResetPasswordEmailJob
  
  def self.perform(user_id)
    user = User.find(user_id)
    reset_password_link = user.reset_password_link
    mail = UserMailer.reset_password(user, reset_password_link)
    mail.deliver
    Email.create!({
      mailer: mail.meta_data.mailer_id, 
      user_id: user.id, 
      email_address: user.email 
    })
  end
  
end
