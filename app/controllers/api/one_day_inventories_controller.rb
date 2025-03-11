class Api::OneDayInventoriesController < Api::BaseController
  
  SYSTEM_BOOKING_JSON = {
    include: { book: Book::JSON_WITH_LINKS },
    methods: [:uid, :pending?, :internal, :send_confirmed?, :needs_confirm?, :swap_offer_list, :refundable_amount, :paid_on, :cancellable_swap?, :swap_reservation_date]
  }
  
  EXTERNAL_BOOKING_JSON = {
    methods: [:send_confirmed?, :needs_confirm?, :uid]
  }
  
  before_action :require_current_member_user
  
  def index
    if list.present? && params[:date].present?
      @one_day_inventory = list.one_day_inventories.where(date: params[:date]).first_or_initialize do |odi|
        odi.mirror_weekly(list.inventories)
      end
      render json: days_data_json, status: :ok
    else
      render_404
    end    
  end
  
  def create
    if list.present? && params[:date].present?
      @one_day_inventory = list.one_day_inventories.where(date: params[:date]).first_or_initialize
      @one_day_inventory.source = 'manual'
      if @one_day_inventory.update(create_params)
        render json: days_data_json, status: :ok
      else
        render json: { success: false, message: @one_day_inventory.errors.full_messages.first }, status: :bad_request
      end
    else
      render_404
    end
  end
  
  private 
  
  def list
    @list ||= current_member_user.lists.find_by_id(params[:list_id])
  end
  
  def create_params
    params.require(:one_day_inventory).permit(:solo, :feature, :mention)
  end
  
  def days_data_json
    days_data = @one_day_inventory.days_data(includes: [{book: [:book_links, :user]}, :promo_send_confirmation, :connect_payments, :swap_reservation])
    { 
      date: @one_day_inventory.date.to_s,
      list_id: list.id,
      one_day_inventory: @one_day_inventory.as_json, 
      pending_system_bookings: {
        solo: days_data.pending_system_bookings.select(&:solo?).as_json(SYSTEM_BOOKING_JSON),
        feature: days_data.pending_system_bookings.select(&:feature?).as_json(SYSTEM_BOOKING_JSON),
        mention: days_data.pending_system_bookings.select(&:mention?).as_json(SYSTEM_BOOKING_JSON)
      },
      accepted_system_bookings: {
        solo: days_data.accepted_system_bookings.select(&:solo?).as_json(SYSTEM_BOOKING_JSON),
        feature: days_data.accepted_system_bookings.select(&:feature?).as_json(SYSTEM_BOOKING_JSON),
        mention: days_data.accepted_system_bookings.select(&:mention?).as_json(SYSTEM_BOOKING_JSON)
      },
      external_bookings: {
        solo: days_data.external_bookings.select(&:solo?).as_json(EXTERNAL_BOOKING_JSON),
        feature: days_data.external_bookings.select(&:feature?).as_json(EXTERNAL_BOOKING_JSON),
        mention: days_data.external_bookings.select(&:mention?).as_json(EXTERNAL_BOOKING_JSON)
      },
      remaining_inventory: {
        solo: days_data.solos_remaining,
        feature: days_data.features_remaining,
        mention: days_data.mentions_remaining
      }
    }
  end
    
end
