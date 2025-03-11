class Api::ExternalReservationsController < Api::BaseController

  before_filter :require_current_member_user


  def create
    ext_booking = list.external_reservations.new(external_reservation_params)
    if blank_booking?
      render json: { success: true, booking: ext_booking.as_json }, status: :ok
    elsif ext_booking.save
      render json: { success: true, booking: ext_booking.as_json }, status: :ok
    else
      render json: { success: false, error: ext_booking.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def update
    ext_booking = list.external_reservations.find_by_id(params[:id])
    if ext_booking.present?
      if blank_booking?
        if ext_booking.send_confirmed?
          render json: { success: false, error: "You cannot delete a confirmed promo" }, status: :bad_request
        else
          ext_booking.destroy
          render json: { success: true, booking: nil }, status: :ok
        end
      elsif ext_booking.update(external_reservation_update_params)
        if ext_booking.send_confirmed? && ext_booking.previous_changes.include?("book_owner_email")
          HandlePromoSendConfirmationWorker.perform_in(HandlePromoSendConfirmationWorker.job_delay, ext_booking.id, ext_booking.clazz)
        end
        render json: { success: true, booking: ext_booking.as_json }, status: :ok
      else
        render json: { success: false, error: ext_booking.errors.full_messages.first }, status: :bad_request
      end
    else
      render_404
    end
  end
  
  def destroy
    
  end

  protected 

  def list
    list ||= current_member_user.lists.find_by_id(params[:list_id])
  end
  
  def external_reservation_params
    params.permit(:date, :inv_type, :book_owner_name, :book_title, :book_owner_email, :book_link).select { |k,v| v.present? }
  end
  
  def external_reservation_update_params
    params.permit(:book_owner_name, :book_title, :book_owner_email, :book_link)
  end
  
  def blank_booking?
    external_reservation_update_params.values.all?(&:blank?)
  end
  
  def confirm_send?
    params[:confirm_send] == "true"
  end

end