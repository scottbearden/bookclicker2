class BookingCalendarsController < ApplicationController
  
  before_filter :sign_in_via_auth_token_param, only: [:swap]
  before_filter :require_current_member_user
  before_filter :redirect_prohibited_users
  before_filter :make_modal_wide
  
  RESERVATION_JSON = {
    include: { book: Book::JSON_WITH_LINKS },
    methods: [:date_pretty, :list, :pending?, :internal, :send_confirmed?, :swap_offer_list, :refundable_amount, :paid_on]
  }
  
  
  def show
    @preselected_book = current_member_user.books.find_by_id(params[:preselected_book_id])
    @list = List.active.find_by_id(params[:list_id]).as_json(except: [:user_id], methods: [:active_member_count_delimited])
    if !@list.present?
      return render_404
    end
    render :show
  end

  def swap
    if arriving_via_auto_login? #hack to avoid React redirects based on query string params
      return redirect_to "/swap_calendar/#{params[:reservation_id]}"
    end
    @reservation = current_member_user.reservations_as_seller.find_by_id(params[:reservation_id])
    if @reservation.present? && @reservation.swap_offer?
      @list = @reservation.swap_offer_list

      if !@reservation.open_swap_offer?
        flash.now[:error] = "This swap offer is no longer available"
        return render_422
      elsif !@list.try(:active?)
        flash.now[:error] = "The author has removed this list from the marketplace"
        return render_422
      else
        @list = @list.as_json(except: [:user_id], methods: [:active_member_count_delimited] )
        @reservation = @reservation.as_json(RESERVATION_JSON)
        return render :swap
      end
    else
      render_404
    end
  end
  
  def arriving_via_auto_login?
    params[:bc_token].present?
  end
  

end
