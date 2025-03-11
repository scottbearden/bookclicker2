class Api::UsersController < Api::BaseController

  before_filter :require_current_assistant_or_member_user
  before_filter :block_assistant, only: [:destroy_member]
  
  def send_verification_email
    EmailVerificationJob.delay.perform(current_assistant_or_member_user.id)
    render json: { success: true}, status: :ok
  end

  def auto_subscribe
    user = current_assistant_or_member_user
    if user.update(auto_subscribe_params)
      render json: { 
        success: true, 
        auto_subscribe_on_booking: user.auto_subscribe_on_booking?,
        auto_subscribe_email: user.auto_subscribe_email
      }, status: :ok
    else
      render json: { success: false, message: user.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def email_subscribe
    user = current_assistant_or_member_user
    if user.update(params.permit(:bookings_subscribed, :confirmations_subscribed, :messages_subscribed))
      render json: { 
        success: true, 
        bookings_subscribed: user.bookings_subscribed?, 
        confirmations_subscribed: user.confirmations_subscribed?,
        messages_subscribed: user.messages_subscribed?
      }, status: :ok
    else
      render json: { success: false, message: user.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def show
    render json: {
      user: current_assistant_or_member_user.as_json(only: [:auto_subscribe_on_booking]),
      lists: current_member_user.lists.active.includes(:inventories).as_json(except: [:user_id], methods: [:inv_types]),
      books: current_member_user.books.includes(:book_links, :pen_name).as_json(Book::JSON_WITH_LINKS),
      pen_names: current_member_user.pen_names_used.not_promo_service.as_json(except: [:user_id])
    }
  end
  
  def update_basic_info
    user = current_assistant_or_member_user
    if user.update(basic_info_params)
      render json: user.as_json(only: [:email, :email_verified_at]), status: :ok
    else
      render json: { success: false, message: user.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def update_country
    country = params[:country].presence
    if current_assistant_or_member_user.update(country: country)
      render json: {success: true}, status: :ok
    else
      render json: {success: false}, status: :bad_request
    end
  end
  
  def destroy_member
    
    current_member_user.lists.update_all(status: "inactive")
    
    affected_lists = []
    current_member_user.api_keys.each do |api_key|
      affected_lists.concat(api_key.affected_lists)
    end
    affected_books = current_member_user.affected_books
    
    if affected_lists.length > 0 || affected_books.length > 0
      return render json: {
        affected_lists: Reservation.settle_associated_reservations_json(affected_lists),
        affected_books: Reservation.settle_associated_reservations_json(affected_books),
        message: "The following lists have bookings on their calendars.  You must resolve all these bookings in order to delete your account."
      }, status: :ok
    else
      current_member_user.close_member_account!
      logout
      flash[:notice] = "Your account has been closed."
      return render json: {
        affected_lists: [],
        affected_books: [],
        message: "Your account has been closed."
      }, status: :ok
    end
  end
  
  private

  def auto_subscribe_params
    params.permit(:auto_subscribe_on_booking, :auto_subscribe_email)
  end
  
  def basic_info_params
    user_attrs = params.permit(:email, :first_name, :last_name)
    for attribute in [:first_name, :last_name]
      if user_attrs[attribute]
        user_attrs[attribute] = user_attrs[attribute].presence
      end
    end
    user_attrs
  end
  
end
