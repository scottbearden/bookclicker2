class CalendarsController < ApplicationController
  
  before_action :require_current_member_user
  before_action :redirect_prohibited_users
  before_action :make_modal_wide
  
  def show
    @list = current_member_user.lists.find(params[:id]).as_json(except: [:user_id], methods: [:active_member_count_delimited])
    @is_mobile = mobile_device?
    @seller = current_member_user.as_json(only: [:first_name, :email], methods: [:full_name])
  end
  
end