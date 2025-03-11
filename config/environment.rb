# Load the Rails application.
require_relative "application"

ActionMailer::Base.delivery_method = :mailgun
ActionMailer::Base.mailgun_settings = {
  api_key: ENV['mailgun_api_key'],
  domain:  ENV['mailgun_domain']
}

# Initialize the Rails application.
Rails.application.initialize!
