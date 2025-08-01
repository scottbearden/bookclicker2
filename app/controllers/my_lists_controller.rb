class MyListsController < ApplicationController
  
  before_action :require_current_member_user
  before_action :redirect_prohibited_users
  
  def index
    render :index
  end
  
  def show
    render :index
  end
  
  def selections
    render :index
  end
  
  def update_selections
    if current_member_user.update(lists_statuses_params)
      flash[:success] = "Your list selections have been saved"
      redirect_to "/my_lists"
    else
      flash[:error] = current_member_user.errors.full_messages.first
      redirect_back(fallback_location: root_path)
    end
  end
  
  def update
    #removed
  end
  
  private
  
  def list_params
    params.permit(:solo_price, :mention_price, :feature_price, :genre_id)
  end
  
  def inventory_params
    params.fetch(:inventories, {}).permit!
  end
  
  def lists_statuses_params
    params.permit({ :lists_attributes => [:id, :status, :pen_name_id] })
  end
  
end