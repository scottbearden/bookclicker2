Mailgun.configure do |config|
  config.domain  = ENV['mailgun_domain']
  config.api_key = ENV['mailgun_api_key']
end