class HomepagesController < ApplicationController
  
  before_filter :send_current_user_to_landing_page, only: [:root, :landing]

  def root
    if cookies[:has_signed_in] == "true"
      return redirect_to('/login')
    else
      render :landing
    end
  end
  
  def landing
    render :landing
  end

end
