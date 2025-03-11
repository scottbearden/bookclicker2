class LaunchesController < ApplicationController
  
  before_action :require_current_member_user
  before_action :redirect_prohibited_users
  
  def show
    book = current_member_user.books.find_by_id(params[:my_book_id])
    return render_404 unless book.present?
    
    @book = book.as_json_with_links
    @books = current_member_user.books.as_json(only: [:id, :title])
    @promos = book.data_for_launch_page[:promos]
    @data_for_chart = book.data_for_launch_page[:data_for_chart]
    render :show
  end
  
end
