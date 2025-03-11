class Api::ConfirmPromosController < Api::BaseController

  before_action :require_current_member_user, only: [:create]


  def create
    if reservation.present?
      promo_send_confirmation = reservation.promo_send_confirmation || reservation.build_promo_send_confirmation
      promo_send_confirmation.seller_confirmed_at = Time.now
      promo_send_confirmation.campaign_id = campaign.try(:id)
      promo_send_confirmation.campaign_preview_url = params[:campaign_preview_url].presence
      
      if promo_send_confirmation.save
        reservation.update_columns(book_owner_email_params.to_h) if !reservation.internal && book_owner_email_params.present?
        
        HandlePromoSendConfirmationWorker.perform_in(HandlePromoSendConfirmationWorker.job_delay, reservation.id, reservation.clazz)
        render json: { success: true }, status: :ok
      else
        render json: { success: false, message: promo_send_confirmation.errors.full_messages.first }, status: :bad_request
      end
    else
      render json: { success: false, message: 'Could not locate booking or email campaign'}, status: :bad_request
    end
  end
  
  def options 
    if reservation.present?
      render json: { 
        success: true, 
        reservation: reservation.as_json(Reservation::AS_JSON_FOR_CONFIRM_PROMO_OPTIONS)
      }
    else
      render json: { success: false, message: 'Could not locate booking'}, status: :bad_request
    end
    
  end
  
  protected 
  
  def reservation
    if params[:reservation_type] == "ExternalReservation"
      @reservation ||= current_member_user.external_reservations.find_by_id(params[:reservation_id])
    else
      @reservation ||= current_member_user.reservations_as_seller.find_by_id(params[:reservation_id])
    end
  end
  
  def list
    @list ||= reservation.try(:list)
  end

  def campaign
    if params[:campaign_id].present?
      @campaign ||= reservation.list.campaigns.find_by_id(params[:campaign_id])
    end
  end
  
  
  def book_owner_email_params
    if Email.valid?(params[:book_owner_email])
      params.permit(:book_owner_email)
    end
  end

end