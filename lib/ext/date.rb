class Date
  def pretty
    self.strftime("%A, %B") + " " + self.day.ordinalize
  end
  
  def pretty_with_year
    self.strftime("%B") + " " + self.day.ordinalize + ", " + self.strftime("%Y")
  end

  def american
    self.strftime("%m/%d/%y")
  end

  def day_of_week
    self.strftime('%A').downcase
  end
  
  def to_int
    to_s.gsub("-","").to_i
  end
  
  def in_english
    self.strftime("%B") + " " + self.day.ordinalize
  end
  
  def self.today_in_local_timezone
    if Time.zone.present?
      Time.zone.now.to_date
    else
      Date.today
    end
  end
  
  def self.valid_sql_date(str)
    if str.present? && str.match(/^\d{4}-\d{2}-\d{2}$/)
      Date.parse(str)
    end
  rescue
    nil
  end

  def self.safe_parse(str)
    Date.parse(str)
  rescue
    nil
  end
  
end