module AmazonProductApi

  def self.parse_asin(url)
    if url.present? && url.match(/\/dp\/(\w{10})/)
      url.match(/\/dp\/(\w{10})/)[1]
    end
  end

  def self.url_from_asin(asin)
    "https://www.amazon.com/dp/#{asin}"
  end

  def self.shorten_url(url)
    asin = parse_asin(url)
    if asin.present?
      url_from_asin(asin)
    end
  end

  def self.lookup_by_url(url)
    res = get_html_via_proxy(url)
    return OpenStruct.new(valid: false) unless res.status.include?("200")
    html = Nokogiri::HTML(res.read)
    data = {}
    data[:title] = html.xpath('//span[@id="ebooksProductTitle"]/text()').to_s.presence || html.xpath('//span[@id="productTitle"]/text()').to_s.presence
    data[:amazon_author] = html.xpath('//a[@class="a-link-normal contributorNameID"]/text()').to_s
    data[:cover_image_url] = html.xpath('//img[@id="imgBlkFront"]').to_s.match(/https[^\"]+\.jpg/).try(:[], 0) || html.xpath('//img[@id="ebooksImgBlkFront"]').to_s.match(/https[^\"]+\.jpg/).try(:[], 0)
    data[:review_count] = html.xpath('//span[@id="acrCustomerReviewText"]/text()').to_s.gsub(",","").match(/([0-9]+)\s/).try(:[], 1)
    data[:avg_review] = html.xpath('//div[@id="averageCustomerReviews"]/span/span[@id="acrPopover"]/@title').to_s.match(/([0-5]\.?[0-9]?)\sout\sof\s5/).try(:[], 1)
    data[:pub_date] = html.xpath('//table[@id="productDetailsTable"]//b[contains(text(),"Publication Date:")]/parent::*/text()').to_s.presence
    if data[:pub_date]
      data[:pub_date] = Date.safe_parse(data[:pub_date])
    end
    data[:book_rank] = html.xpath('//table[@id="productDetailsTable"]//b[contains(text(),"Amazon Best Sellers Rank:")]/parent::*/text()').to_s.gsub(",","").presence
    if data[:book_rank]
      data[:book_rank] = data[:book_rank].match(/#([0-9]+)\s/).try(:[], 1)
    end
    data
  rescue => e
    puts e.message
    {}
  end

  def self.author_profile_lookup(url)
    res = get_html_via_proxy(url)
    return OpenStruct.new(valid: "false") unless res.status.include?("200")
    html = Nokogiri::HTML(res.read)
    #author_name =  html.xpath('//*[@id="authorName"]/h1/text()').to_s.strip
    #author_image = html.xpath('//div[@id="authorImage"]/img/@src')[0].try(:value)
    author_name =  html.xpath('/html/body/div[1]/div[2]/div/div[3]/div/div/div/div/div[1]/text()').to_s.strip
    author_image = html.xpath('/html/body/div[1]/div[2]/div/div[2]/div/div/div/div/div[2]/div/div[1]/div/a/img/@src')[0].try(:value)

    #/html/body/div[1]/div[2]/div/div[3]/div/div/div/div/h1

    valid = author_name.present? || author_image.present?
    { valid: valid, author_name: author_name, author_image: author_image }
  rescue Exception => e
    { value: false, kevin: e }
  end


  def self.get_html_via_proxy(url)
  if URI.parse(url).scheme.nil?
    url = "https://#{url}"
  end
  proxy = proxies.sample
  open(
    url,
    proxy_http_basic_authentication: [
      "http://#{proxy}",
      ENV['proxy_bonanza_username'],
      ENV['proxy_bonanza_password']
    ],
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36"
  )
end


  def self.proxies
    @proxies ||= Proxy.all.map(&:ip)
  end

end
