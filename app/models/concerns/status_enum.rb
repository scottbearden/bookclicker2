module StatusEnum
    extend ActiveSupport::Concern
  
    included do
      enum :status, { active: 1, inactive: 0 }, prefix: true, scopes: true
    end
  end