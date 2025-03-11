class ProcessListSubscriptionsJob

  def self.perform
    puts "#{Time.now}: -------- start ProcessListSubscriptionsJob -----------"
    ListSubscription.all.select(&:unprocessed?).each do |list_subscription|
      begin
        list_subscription.process
      rescue => e
        puts e.message
      end
    end
    puts "#{Time.now}: -------- start ProcessListSubscriptionsJob -----------"
    puts "\n"
  end

end