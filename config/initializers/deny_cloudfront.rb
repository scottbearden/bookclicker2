require_relative '../../app/services/cloudfront_denier'

Rails.application.config.middleware.use CloudfrontDenier, target: SITE_URL
