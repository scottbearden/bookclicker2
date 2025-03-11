class MarketplacesController < ApplicationController
  
  before_action :require_current_member_user
  before_action :redirect_prohibited_users
    
  def show
    if current_member_user.lists.blank? && cookies[:viewed_integrations_warning].blank?
      flash.now[:danger] = "You have no lists connected. Please #{"<a href='/integrations'>set up an integration</a>".html_safe}."
      cookies[:viewed_integrations_warning] = true
    end
    withFlash_component
  end
  
end