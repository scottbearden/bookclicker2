class Api::BaseController < ApplicationController
  
  skip_before_action :verify_authenticity_token
    
end