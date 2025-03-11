Mailgun.configure do |config|
  config.domain  = Figaro.env.mailgun_domain
  config.api_key = Figaro.env.mailgun_api_key
end