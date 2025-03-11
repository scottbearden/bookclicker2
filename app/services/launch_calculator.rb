class LaunchCalculator
  
  attr_reader :promos
  
  def initialize(promos)
    @promos = promos
  end
  
  def promo_emails_by_day
    @promo_emails_by_day ||= begin
      result = {}
      promos.group_by(&:date).each do |date, promos| 
        solos = promos.select(&:solo?).map(&:list_size).compact.sum
        features = promos.select(&:feature?).map(&:list_size).compact.sum
        mentions = promos.select(&:mention?).map(&:list_size).compact.sum
        num_emails = solos + features + mentions
        result[date] = OpenStruct.new(
          date: date, 
          num_emails: num_emails,
          solos: solos,
          features: features,
          mentions: mentions
        )
      end
      result
    end
  end
  
  def calculate
    if promo_emails_by_day.length == 0
      first_date = Date.today_in_local_timezone
      last_date = Date.today_in_local_timezone + 6.days
    elsif promo_emails_by_day.length == 1
      first_date = promo_emails_by_day.keys.min - 3.days
      last_date = promo_emails_by_day.keys.max + 3.days
    elsif promo_emails_by_day.length == 2
      first_date = promo_emails_by_day.keys.min - 2.day
      last_date = promo_emails_by_day.keys.max + 2.day
    else
      first_date = promo_emails_by_day.keys.min - 1.day
      last_date = promo_emails_by_day.keys.max + 1.day
    end
    (first_date..last_date).map do |date|
      day = {}
      day[:date] = date
      daily_counts = promo_emails_by_day[date]
      if daily_counts
        day[:num_emails] = daily_counts.num_emails
        day[:solos] = daily_counts.solos
        day[:features] = daily_counts.features
        day[:mentions] = daily_counts.mentions
      end
      day
    end
  end
  
end