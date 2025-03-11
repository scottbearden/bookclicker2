class Email < ApplicationRecord
  
  belongs_to :user
  
  
  def self.banned?(email)
  	email.match(/aweber.*bookclicker/)
  end

  def self.valid?(email)
    !!/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/.match(email)
  end
  
  
end