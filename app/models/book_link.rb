class BookLink < ApplicationRecord
  belongs_to :book, -> { unscope(where: :deleted) }
  
  validates_presence_of :link_url
  validates_format_of :link_url, with: /\A[^\s]+\z/
  validates_format_of :link_url, with: /\./

  before_validation :clean_link_url #strip, downcase, add scheme
  before_validation :set_website_name #set host (e.g. www.amazon.com)

  before_save :shorten_amazon_link, if: :amazon?
  
  def amazon?
    website_name == "www.amazon.com"
  end

  def google_play?
    website_name == "play.google.com"
  end

  def itunes?
    website_name == "itunes.apple.com"
  end
  
  def set_website_name
    self.website_name = get_link_url_host
  end
  
  def shorten_amazon_link
    if short_url = AmazonProductApi.shorten_url(self.link_url)
      self.link_url = short_url
    end
  end
  
  def clean_link_url
    self.link_url = self.link_url.try(:strip)
    ensure_scheme
  end
  
  def get_link_url_host
    URI.parse(self.link_url).host.downcase
  rescue
    nil
  end
  
  def ensure_scheme
    if self.link_url.present? && URI.parse(self.link_url).scheme.nil?
      self.link_url = "https://#{self.link_url}"
    end
  rescue
    nil
  end
end
