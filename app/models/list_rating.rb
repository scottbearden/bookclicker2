class ListRating < ApplicationRecord
  
  belongs_to :list
  belongs_to :user
  
  
  validates :list_id, :uniqueness => {:scope => :user_id}, allow_nil: false
  
end