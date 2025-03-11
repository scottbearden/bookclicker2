class OneDayInventoriesController < ApplicationController

  before_action :require_current_member_user
  before_action :redirect_prohibited_users

  def create
    #no longer used
  end


  private


  def one_day_inventory_attributes
    params.permit(:source, :solo, :feature, :mention)
  end

end