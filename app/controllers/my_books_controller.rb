class MyBooksController < ApplicationController
  
  before_filter :require_current_member_user
  before_filter :redirect_prohibited_users
  before_filter :withFlash_component, only: [:show, :new]
  
  def show
    book = current_member_user.books.find_by_id(params[:id])
    if book.present?
      @book = book.as_json_with_links
      render :page
    else
      return render_404
    end
  end
  
  def new
    render :page
  end
  
  def create
    book = current_member_user.books.new(book_params)
    if book.save
      flash[:success] = "You've successfully added a book"
      if params[:cal_back] == "launch"
        redirect_to "/my_books/#{book.id}/launch"
      else
        redirect_to pen_names_path
      end
    else
      flash[:notice] = book.errors.full_messages.first
      redirect_to :back
    end
  end
  
  def update
    book = current_member_user.books.find(params[:id])
    if book.update(book_params)
      flash[:success] = "Book info saved"
      redirect_to pen_names_path
    else
      flash[:error] = book.errors.full_messages.first
      redirect_to :back
    end
  end
  
  private
  
  def book_params
    params.require(:book).permit(
      :title, :pen_name_id, :blurb, :cover_image_url, :launch_date, :review_count, :avg_review, :book_rank, :amazon_author, :pub_date,
      { :book_links_attributes => [:id, :link_url, :_destroy] })
  end
  
end
