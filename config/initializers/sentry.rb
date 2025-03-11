# require 'active_support/parameter_filter'

# Sentry.init do |config|
#   filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
#   config.before_send = lambda do |event, hint|
#     filter.filter(event.to_hash)
#   end
# end

# Initialize Sentry
require 'active_support/parameter_filter'

Sentry.init do |config|
  config.dsn = ENV['sentry_dsn']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    filter.filter(event.to_hash)
  end

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
  # Set profiles_sample_rate to profile 100%
  # of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = 1.0
end