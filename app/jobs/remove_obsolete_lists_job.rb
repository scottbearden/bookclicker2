class RemoveObsoleteListsJob
  include Sidekiq::Worker
  
  def perform
    
    puts "Running RemoveObsoleteListsJob at #{Time.now}"
    return nil unless List.refresh_completed_recently?
    
    lists = List.where("last_refreshed_at < NOW() - interval 1 week").includes(:reservations, :pen_name)
    #this query's job is to narrow the search to obsolete lists.
    
    lists.each do |list|
      #this block's job is to actually remove or delete obsolete lists
      next unless list.not_found_recently_in_api?
      
      if list.reservations.blank?
        list.destroy
      else
        list.update_column(:status, 'inactive')
      end
    end
    
    puts "Finishing RemoveObsoleteListsJob at #{Time.now}"
    
  end
  
end