SITE_HOST = ENV.fetch('SITE_HOST', 'example.com')
SITE_SCHEME = ENV.fetch('SITE_SCHEME', 'http')
SITE_URL = '#{SITE_SCHEME}://#{SITE_HOST}'
