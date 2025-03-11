module Mail
  class Message
    
    def meta_data
      @meta_data ||= OpenStruct.new
    end
    
  end
end