class Api::MyBooksController < Api::BaseController
  
  before_filter :require_current_member_user
  
  def index
    render json: books_json, status: :ok
  end
  
  def show
    book = current_member_user.books.find(params[:id])
    render json: book.as_json_with_links, status: :ok 
  end
  
  def launch_data
    book = current_member_user.books.find(params[:id])
    render json: {
      promos: book.data_for_launch_page[:promos],
      data_for_chart: book.data_for_launch_page[:data_for_chart],
      book_id: book.id,
      books: current_member_user.books.as_json(only: [:id, :title])
    }
  end
  
  def create
    book = current_member_user.books.new(params.permit(:title, :pen_name_id))
    if book.save
      render json: { success: true, books: books_json, book: book.as_json_with_links }, status: :ok
    else
      render json: { success: false, message: book.errors.full_messages.first }, status: :bad_request
    end
  end
  
  def update
    book = current_member_user.books.find_by_id(params[:id]) 
    if book.present?
      if book.update(book_params)
        render json: { success: true, book: book.as_json_with_links }, status: :ok
      else
        render json: { success: false, error: book.errors.full_messages.first }, status: :bad_request
      end
  	else
      render_404
    end
  end

  def destroy
    book = current_member_user.books.find_by_id(params[:id])
    if book.present?
      pen_name = book.pen_name
      if book.update(deleted: true)
        render json: {success: true, message: "Your book '#{book.title}' has been deleted", books: books_json_by_pen_name(pen_name)}, status: :ok
      else
        render json: {success: false, message: (book.errors.full_messages.first || "Book was not deleted")}, status: :bad_request
      end
  	else
      render_404
    end
  end
  
  def books_json
    current_member_user.books.includes(:book_links, :pen_name).as_json(Book::JSON_WITH_LINKS)
  end
  
  def books_json_by_pen_name(pen_name)
    pen_name.books.where(user_id: current_member_user.id).includes(:book_links, :pen_name).as_json(Book::JSON_WITH_LINKS)
  end
  
  def book_params
    params.require(:book).permit(
      :title, :pen_name_id, :blurb, :cover_image_url, :launch_date, :amazon_author, :review_count, :avg_review, :pub_date, :book_rank,
      { :book_links_attributes => [:id, :link_url, :_destroy] })
  end
  
end
