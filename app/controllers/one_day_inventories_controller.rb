class OneDayInventoriesController < ApplicationController

  before_filter :require_current_member_user
  before_filter :redirect_prohibited_users

  def create
    #no longer used
  end


  private


  def one_day_inventory_attributes
    params.permit(:source, :solo, :feature, :mention)
  end

end