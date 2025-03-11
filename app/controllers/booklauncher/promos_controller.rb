class Booklauncher::PromosController < ApplicationController
    
  def create
    book = current_member_user.books.find_by_id(params[:book_id])
    if book.present?
      begin 
        if book.update(promos_attributes)
          flash[:success] = "Information updated"
        else
          flash[:error] = book.errors.full_messages.first
        end
      rescue => e
        flash[:error] = e.message
      end
      redirect_to "/booklauncher/book/#{params[:book_id]}"
    else
      render_404
    end
  end
  
  
  def promos_attributes
    params.fetch(:book, {}).permit(
      { :promos_attributes => [:id, :name, :list_size, :promo_type, :date, :uuid, :_destroy] })
  end
  
end