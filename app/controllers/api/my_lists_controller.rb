class Api::MyListsController < Api::BaseController
  
  before_action :require_current_member_user
  
  def index(all: false)
    if refresh?
      MailingListsUpdatorJob.perform_for_user(current_member_user.id)
    end
    query_base = current_member_user.lists.includes(:genres, :inventories).order(:id)
    query_base = query_base.status_active unless params[:all].present? || all
    render json: {
      lists: query_base.as_json(except: [:user_id], methods: [:inv_types, :Platform, :active_member_count_delimited]),
      pen_names: current_member_user.pen_names_used.as_json(except: [:user_id])
    }, status: :ok
  end
  
  def show
    render json: list.as_json( 
                       methods: [:inventories_scaffolded, :Platform, :active_member_count_delimited],
                       include: [:genres]
                  ), status: :ok 
  end
  
  def update
    if list.update(list_params)
      list.api_key.try(:update_mailing_lists)
      return index(all: true)
    else
      render json: { success: false, message: list.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def cutoff_date
    if list.update(params.permit(:cutoff_date))
      return render json: { success: true, cutoff_date: list.cutoff_date }, status: :ok
    else
      return render json: { success: false, cutoff_date: list.reload.cutoff_date, message: list.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def inventories_genres_prices
    update_inventories
    update_genres
    update_prices
    return render json: { success: true }, status: :ok
  end
  
  def refresh?
    last_update = current_member_user.lists_last_refreshed_at
    params["refresh"] == "true" || 
    (params["refresh"] == "maybe" && (last_update.nil? || last_update <  20.minutes.ago))
  end
  
  private
  
  def list_params
    params.permit(:pen_name_id, :status)
  end
  
  def list
    @list ||= current_member_user.lists.find_by_id(params[:id])
  end
  
  #INVENTORIES######
  def update_inventories
    for inv_type in Inventory.all_types
      inventory = list.inventories.where(inv_type: inv_type).first_or_initialize
      inventory.attributes = inventory_params[inv_type]
      inventory.save!
    end
  rescue
  end
  
  def inventory_params
    params.require(:inventories).permit(:solo => DAYS_OF_WEEK, :feature => DAYS_OF_WEEK, :mention => DAYS_OF_WEEK)
  end
  
  #GENRES############
  def update_genres
    ListsGenre.where(list_id: list.id).delete_all
    ListsGenre.create!(lists_genres_attributes) if lists_genres_attributes.present?
  rescue
  end
  
  def lists_genres_attributes
    @lists_genres_attributes ||= begin
      genre_ids = params[:genres].present? ? params[:genres].values.map { |g| g["id"] || g["value"] } : []
      genre_ids.map { |genre_id| { list_id: list.id, genre_id: genre_id } }
    end    
  end
  
  #PRICES############
  def update_prices
    list.update(list_prices_params)
  end
  
  def list_prices_params
    params.require(:prices).permit(:solo_price, :feature_price, :mention_price, :solo_is_swap_only, :feature_is_swap_only, :mention_is_swap_only)
  end
  
end