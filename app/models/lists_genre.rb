class ListsGenre < ApplicationRecord
  
  
  belongs_to :genre
  belongs_to :list
  
  scope :primary, -> { where(primary: 1) }
  
end