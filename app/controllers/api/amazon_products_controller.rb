class Api::AmazonProductsController < Api::BaseController
  
  before_action :require_current_member_user
  
  def index
    attrs = AmazonProductApi.lookup_by_url(params[:url])
    render json: attrs, status: :ok
  end
  
  def profile
    attrs = AmazonProductApi.author_profile_lookup(params[:url])
    render json: attrs, status: :ok
  end
  
end