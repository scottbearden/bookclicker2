Aws.config.update({
   credentials: Aws::Credentials.new(Figaro.env.aws_access_key_id, Figaro.env.aws_secret_access_key)
})

Aws.config.update({region: 'ca-central-1'})