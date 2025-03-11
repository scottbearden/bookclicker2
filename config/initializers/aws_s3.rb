Aws.config.update({
  credentials: Aws::Credentials.new(ENV['aws_access_key_id'], ENV['aws_secret_access_key'])
})

Aws.config.update({region: 'ca-central-1'})