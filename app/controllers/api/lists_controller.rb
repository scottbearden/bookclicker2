class Api::ListsController < Api::BaseController
  
  before_action :require_current_member_user
  
  def index
    query_base = List.marketplace_base_query(:genres, :inventories, :pen_name, :user)
                 
    if list_params[:search].present?
      sql = List.marketplace_search(list_params[:search])
      query_base = query_base.where(sql)  
    end
    
    if list_params[:sort].present?
      order_by_clause = handle_sort_param(list_params[:sort])
      query_base = query_base.order(Arel.sql(order_by_clause))
    else
      query_base = query_base.order(sponsored_tier: :desc, last_action_at: :desc)
    end
    
    if list_params[:favorites].present?
      query_base = query_base.where("exists (Select 1 from list_ratings rg where rg.user_id = #{current_member_user.id} and rg.list_id = lists.id and rg.rating = 1)")
    end
    
    if start_date.present?
      query_base = query_base.where("(? <= if(lists.cutoff_date is null, current_date + interval 1 year, lists.cutoff_date))", list_params[:start_date])
    end
    
    if end_date.present?
      query_base = query_base.where("current_date <= ?", list_params[:end_date])
    end
    
    if start_date || end_date
      if start_date && end_date && (end_date - start_date).to_i.between?(0, 5)
        days_of_week = (start_date..end_date).map(&:day_of_week)
      else
        days_of_week = DAYS_OF_WEEK
      end
      days_of_week_sql = days_of_week.map { |dow| "inventories.#{dow}" }.join(" or ")
      
      query_base = query_base.where(days_of_week_sql)
    end
    
    if list_params[:preselected_book_id].present?
      query_base = query_base.where("not exists (select 1 from reservations r_already where r_already.book_id = ? and r_already.list_id = lists.id)", list_params[:preselected_book_id].to_i)
    end
    
    if list_params[:genreIds].present?
      genre_ids = list_params[:genreIds].split("-").map(&:to_i)
      genre_query = Genre.convert_ids_to_marketplace_query(genre_ids)
      query_base = query_base.where(genre_query)
    end
    query_base = query_base.page(list_params[:page])
    render json:  {
      lists: query_base.as_json({
        except: [:platform_id, :api_key_id], 
        include: {
          pen_name: {
            only: [:id, :author_name]
          }
        },
        methods: [:inventories, :Platform, :active_member_count_delimited, :author_profile_link_if_verified]
      }),
      my_pen_names: current_member_user.pen_names_used.as_json(only: [:id, :author_name]),
      list_ratings: current_member_user.list_ratings_hash_by_list_id(list_ids: query_base.map(&:id)),
      pagination: pagination(query_base, list_params)
    }, status: :ok
  end
  
  def show
    list = List.find(params[:id])
    render json: list.as_json(except: [:user_id], methods: [:inventories, :active_member_count_delimited])
  end
  
  def rate
    list_rating = current_member_user.list_ratings.where(list_id: params[:id]).first_or_initialize
    list_rating.rating = params[:rating]
    list_rating.save
    render json: {
      list_rating: list_rating
    }, status: :ok
  end
  
  def list_params
    params.permit(:sort, :genreIds, :page, :search, :favorites, :start_date, :end_date, :preselected_book_id)
  end
  
  def handle_sort_param(sort_field)
    sort_order = sort_field[0] == "-" ? "desc" : "asc"
    sort_field = sort_field.sub("-","").sub("_delimited", "")
    if /^(.+)_price$/.match(sort_field)
      swap_only_field = price_to_swap_only_field(sort_field)
      sort_field = "coalesce(#{sort_field},if(#{swap_only_field},1,NULL))"
    end
    "CASE WHEN #{sort_field} IS NULL THEN 1 ELSE 0 END ASC, #{sort_field} #{sort_order}"
  end
  
  def start_date
    Date.valid_sql_date(list_params[:start_date])
  end
  
  def end_date
    Date.valid_sql_date(list_params[:end_date])
  end
  
  def price_to_swap_only_field(field)
    case field
    when "solo_price"
      "solo_is_swap_only"
    when "feature_price"
      "feature_is_swap_only"
    when "mention_price"
      "mention_is_swap_only"
    end
  end
  
end
