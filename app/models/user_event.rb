class UserEvent < ApplicationRecord
  
  belongs_to :user
  
  validates_presence_of :user, :event
  
  
end