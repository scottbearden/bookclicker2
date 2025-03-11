class Api::ImagesController < Api::BaseController
  
  
  def upload
    raise "Bad file upload" unless tmp_image_file_disk_path.present?
    s3 = Aws::S3::Resource.new
    file_key = SecureRandom.hex
    obj = s3.bucket('bookclicker').object("book_cover_images_#{Rails.env}/#{file_key}")
    obj.upload_file(tmp_image_file_disk_path)
    render json: { success: true,  url: obj.public_url }
  rescue => e
    render json: { success: false,  error: e.message }, status: :bad_request
  end  
  
  
  private
  
  def tmp_image_file_disk_path
    if params[:book][:cover_image].present?
      params[:book][:cover_image].tempfile.path
    end
  end
  
end