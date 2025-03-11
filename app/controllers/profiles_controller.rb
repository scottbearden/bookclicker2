class ProfilesController < ApplicationController
  
  before_filter :require_current_assistant_or_member_user

  FIELDS_FOR_USER = [:id, :role, :email, :email_verified_at, :bookings_subscribed, :confirmations_subscribed, :messages_subscribed, :first_name, :last_name, 
                :auto_subscribe_on_booking, :auto_subscribe_email]
  
  def show
    @user = current_assistant_or_member_user
            .as_json(
              only: FIELDS_FOR_USER, 
              methods: [:full_name, :email_verified?, :email_unless_banned, :assistant?, :full_member?, :last_assistant_invite])
        
    @pen_names = current_assistant_or_member_user.pen_names_used.order(:author_name).as_json
    
    @all_assistants = User.assistant.order(User.order_by_first_name_sql).as_json({
      only: [:id], methods: [:full_name_or_email]
    })
    
    @users_assistants = current_assistant_or_member_user.users_assistants_ordered_json
    
    @list_subscriptions = current_assistant_or_member_user
                          .list_subscriptions.joins(:list)
                          .order(:id).includes(:list)
                          .as_json( ListSubscription.default_as_json )
  end
  
end