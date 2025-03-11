class ConfirmPromosController < ApplicationController

  before_action :sign_in_via_auth_token_param, only: [:select]
  before_action :require_current_member_user
  before_action :redirect_prohibited_users
  
  def select
    @seller = current_member_user.as_json(methods: [:full_name], only: [])
    @internal_reservations = current_member_user
                    .reservations_for_send_confirmation.in_last_months(6)
                    .includes({list: :pen_name}, {book: :pen_name}, :buyer, :promo_send_confirmation, :confirmed_campaign, :connect_payments, :swap_reservation)
                    
    @external_reservations = current_member_user
                             .external_reservations_for_send_confirmation.in_last_months(6)
                             .eager_load(:buyer_by_email, :list, :promo_send_confirmation, :confirmed_campaign)
                             
                             
    @reservations = (@internal_reservations + @external_reservations).sort_by(&reservation_sort_score).as_json(Reservation::AS_JSON_FOR_CONFIRM_PROMO_OPTIONS)
      
    render :select
  end
  
  def confirmed
    select()
  end
  
  private
  
  def reservation_sort_score
    Proc.new do |reservation|
      score = reservation.id == params[:resId].to_i ? -1E10 : 0
      score -= reservation.date.to_int
      score
    end
  end

end
