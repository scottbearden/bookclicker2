# Load the Rails application.
require_relative 'application'

ActionMailer::Base.smtp_settings = {
  :port           => 587,
  :address        => 'smtp.mailgun.org',
  :user_name      => Figaro.env.mailgun_user_name,
  :password       => Figaro.env.mailgun_password,
  :domain         => Figaro.env.mailgun_domain,
  :authentication => :plain
}
ActionMailer::Base.delivery_method = :smtp
# Initialize the Rails application.
Rails.application.initialize!
