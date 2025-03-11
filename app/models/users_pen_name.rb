class UsersPenName < ApplicationRecord
  
  belongs_to :user
  belongs_to :pen_name
  
end
