class MailingListsUpdatorJob
  
  def self.perform(user_id)
    User.find(user_id).api_keys.each do |api_key|
      perform_for_single_api_key(api_key.id)
    end
  end
  
  def self.perform_for_all
    puts "\nBegan MailingListsUpdatorJob.perform_for_all at #{Time.now}"
    User.full_member.each do |u|
      begin
        MailingListsUpdatorJob.perform(u.id)
      rescue => e
        puts "Error for #{u.id}: #{e.message}"
      end
    end
    puts "Ended MailingListsUpdatorJob.perform_for_all at #{Time.now}\n\n\n"
  end
  
  def self.perform_for_single_api_key(api_key_id, pull_all_stats = false)
    api_key = ApiKey.find_by_id(api_key_id)
    return if api_key.nil?
    
    send("update_#{api_key.platform}_lists", api_key)
    if pull_all_stats && api_key.aweber?
      MailingListsUpdatorJob.delay.update_aweber_lists(api_key, true)
    end
  end
  
  def self.update_mailchimp_lists(api_key)
    api = api_key.init_api
    return nil unless api.status == "Good"
    orig_lists = api_key.lists.includes(:reservations)
    #####################################
     
    api_lists = api.get_lists
    puts api_lists
    for li in api_lists
      list = api_key.user.lists.where(platform: api.platform, platform_id: li["id"]).first_or_initialize
      list.update(
        api_key_id: api.api_key_id,
        name: li["name"],
        active_member_count: li["stats"]["member_count"],
        open_rate: (li["stats"]["open_rate"]/100 if li["stats"]["open_rate"].to_f > 0.0),
        click_rate: (li["stats"]["click_rate"]/100 if li["stats"]["click_rate"].to_f > 0.0),
        last_refreshed_at: Time.now
      )
    end
  end
  
  def self.update_mailerlite_lists(api_key)
    api = api_key.init_api
    return nil unless api.status == "Good"
    orig_lists = api_key.lists.includes(:reservations)
    #####################################
    
    groups = api.get_groups
    for group in groups
      list = api_key.user.lists.where(platform: api.platform, platform_id: group["id"]).first_or_initialize
      if group["sent"].to_i > 0
        open_rate = group["opened"].to_f/group["sent"]
        click_rate = group["clicked"].to_f/group["sent"]
      end
      
      list.update(
        api_key_id: api.api_key_id,
        name: group["name"],
        active_member_count: group["active"],
        open_rate: open_rate,
        click_rate: click_rate,
        last_refreshed_at: Time.now
      )

    end
  end
  
  def self.update_convertkit_lists(api_key)
    api = api_key.init_api
    return nil unless api.status == "Good"
    orig_lists = api_key.lists.includes(:reservations)
    #####################################
    
    forms = api.get_forms
    puts forms
    forms.each do |form|
      puts form
      list = api_key.user.lists.where(platform: api.platform, platform_id: form["id"]).first_or_initialize
      list.update(
        api_key_id: api.api_key_id,
        name: form["name"],
        active_member_count: form["total_subscriptions"],
        last_refreshed_at: Time.now
      )
    end
  end
  
  def self.update_aweber_lists(api_key, with_stats = false)
    api = api_key.init_api
    return nil unless api.status == "Good"
    orig_lists = api_key.lists.includes(:reservations)
    #####################################
    
    api_lists = api.get_lists(with_stats: with_stats)
    api_lists.each do |list_attrs|
      list = api_key.user.lists.where(platform: api.platform, platform_id: list_attrs[:id]).first_or_initialize
      list.api_key_id = api.api_key_id
      list.name = list_attrs[:name]
      if list_attrs[:active_member_count].to_i > 0
        list.active_member_count = list_attrs[:active_member_count]
      end
      if list_attrs[:sent].to_i > 0 && list_attrs[:opens].to_i > 0 && list_attrs[:opens] <= list_attrs[:sent]
        list.open_rate = list_attrs[:opens].to_f/list_attrs[:sent].to_f
      end
      if list_attrs[:sent].to_i > 0 && list_attrs[:clicks].to_i > 0 && list_attrs[:clicks] <= list_attrs[:sent]
        list.click_rate = list_attrs[:clicks].to_f/list_attrs[:sent].to_f
      end
      list.last_refreshed_at = Time.now
      list.save
    end
  end
  
end
