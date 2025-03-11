class Api::CampaignsController < Api::BaseController
  
  
  def index
    if list.present?
      render json: {
        campaigns: campaigns,
        can_load_more: campaigns.length >= 5,
        offset: offset + campaigns.length
      }, status: :ok
    else
      render_404
    end
  end
  
  
  def list
    @list ||= current_member_user.lists.find_by_id(params[:list_id])
  end
  
  def offset
    (params[:offset].presence || 0).to_i
  end
  
  def campaigns
    @campaigns ||= list.campaigns_last_5.offset(offset)
  end
  
end