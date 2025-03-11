class ExternalReservationsController < ApplicationController
  
  before_filter :require_current_member_user
  before_filter :redirect_prohibited_users
  
  def destroy
    @external_reservation = current_member_user.external_reservations.find_by_id(params[:id])
    @external_reservation.destroy
    flash[:success] = "Your reservation was removed from your calendar"
    redirect_to :back
  end
  
  def create
    mailing_list = current_member_user.lists.find(params[:list_id])
    @external_reservation = mailing_list.external_reservations.new(external_reservation_params)
    if @external_reservation.save
      flash[:success] = "You added a booking for #{@external_reservation.date}"
    else
      flash[:error] = @external_reservation.errors.full_messages.first
    end
    redirect_to :back
      
  end
  
  
  private
  
  def external_reservation_params
    params
    .permit(:book_title, :book_owner_name, :book_owner_email, :inv_type, :date)
    .select { |field, val| val.present? }
  end
  
end