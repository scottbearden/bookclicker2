SITE_URL = SITE_SCHEME + '://' + SITE_HOST
MAILCHIMP_REDIRECT_URI = "#{SITE_URL}/mailchimp/auth/callback"
AWEBER_CALLBACK_URI = "#{SITE_URL}/aweber/auth/callback"


AMAZON_LOGO_URL = 'https://s3.ca-central-1.amazonaws.com/bookclicker/amazon-logo_transparent.png'

MAILCHIMP_LOGO_URL = "https://s3.ca-central-1.amazonaws.com/bookclicker/mc_freddie_black.png";
AWEBER_LOGO_URL = "https://s3.ca-central-1.amazonaws.com/bookclicker/logo-aweber.png"
MAILERLITE_LOGO_URL = "https://s3.ca-central-1.amazonaws.com/bookclicker/mailerlite.png"
CONVERTKIT_LOGO_URL = "https://s3.ca-central-1.amazonaws.com/bookclicker/ConvertKit.png"

LOGO_URL = "https://s3.ca-central-1.amazonaws.com/bookclicker/logo2-small.png"
LOGO_WITH_TEXT_URL = "https://s3.ca-central-1.amazonaws.com/bookclicker/logo2-transparent.png"
POWERED_BY_STRIPE_LOGO = "https://s3.ca-central-1.amazonaws.com/bookclicker/powered_by_stripe.png"
CONNECT_WITH_STRIPE_LOGO = "https://s3.ca-central-1.amazonaws.com/bookclicker/blue-on-light.png"
CONNECT_WITH_STRIPE_LOGO_2X = "https://s3.ca-central-1.amazonaws.com/bookclicker/blue-on-light@2x.png"

WHEEL_SVG = 'https://s3.ca-central-1.amazonaws.com/bookclicker/wheel.svg'

SELLER_RESPONSE_DAY_LIMIT = 5
BUYER_PAYMENT_HOUR_LIMIT = 72

CAN_DELETE_STUFF_AFTER = 3.weeks

SUPPORT_EMAIL = "no-reply@bookclicker.com"
MAILGUN_TEST_EMAIL = "michael.herold@toptal.com"

BOOK_COVER_PLACEHOLDER_URL = 'https://s3.ca-central-1.amazonaws.com/bookclicker/book_cover_placeholder.jpg'

PLATFORMS = ["mailchimp", "aweber", "mailerlite", "convertkit"]

SIGN_UP_PATH = "/sign_up"

ALERT_CSS_CLASSES = { 
  "danger" => "alert-danger",
  "error" => "alert-danger", 
  "notice" => "alert-warning", 
  "success" => "alert-success",
  "warning" => "alert-warning",
  "info" => "alert-info" }
  
DAYS_OF_WEEK = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
