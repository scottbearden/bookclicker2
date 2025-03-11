class RetrieveSellerEmailCampaignsJob

  def self.perform
    puts "#{Time.now}: -------- start RetrieveSellerEmailCampaignsJob -----------"
    lists_seen = {}
    List.distinct.joins(:recent_reservations).includes(:recent_reservations).each do |list|
      prompt_seller = false
      begin
        if list.api.present?
          list.retrieve_email_campaigns
          prompt_seller = true
        end
        lists_seen[list.id] = true
        
        list.recent_reservations.each do |res|
          if res.campaigns_fetched_at.nil?
            res.update_column(:campaigns_fetched_at, Time.now)
            if prompt_seller
              PromptSellerToConfirmPromoWorker.perform_in(100.seconds, res.id, "system")
            end
          end
        end
      rescue => e
        puts e.message + " - in RetrieveSellerEmailCampaignsJob (list #{list.id})"
      end
    end
    puts "Processed lists for recent Reservation: #{lists_seen.keys}"
    lists_seen = {}
    List.distinct.joins(:recent_external_reservations).includes(:recent_external_reservations).each do |list|
      prompt_seller = false
      begin
        if list.api.present?
          list.retrieve_email_campaigns
          prompt_seller = true
        end
        lists_seen[list.id] = true
        
        list.recent_external_reservations.each do |res|
          if res.campaigns_fetched_at.nil?
            res.update_column(:campaigns_fetched_at, Time.now)
            if prompt_seller
              PromptSellerToConfirmPromoWorker.perform_in(100.seconds, res.id, "manual")
            end
          end
        end
      rescue => e
        puts e.message + " - in RetrieveSellerEmailCampaignsJob (list #{list.id})"
      end
    end
    
    puts "Processed lists for recent ExternalReservation: #{lists_seen.keys}"
    puts "\n"
    puts "#{Time.now}: -------- end RetrieveSellerEmailCampaignsJob -----------"
    puts "\n"
  end

end