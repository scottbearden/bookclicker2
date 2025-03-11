class UsersAssistant < ApplicationRecord
  
  belongs_to :user, -> { full_member }
  belongs_to :assistant, -> { assistant }, class_name: User

  has_many :assistant_payment_requests
  
  validates :assistant_id, :uniqueness => {:scope => :user_id}, allow_nil: false
  
  has_paper_trail
  
  
  def has_interaction?
    assistant_payment_requests.any?(&:ongoing?)
  end
  
  def ui_sort_score
    score = self.id || 0
    if active_payment_request.present?
      score -= 10000000
    end
    score
  end
  
  def can_add_request?
    !has_interaction?
  end
  
  def active_payment_request
    requests = assistant_payment_requests.sort_by(&:id)
    requests.select(&:ongoing?).last || requests.last
  end
  
  def payment_request_json
    active_payment_request.try(:as_ui_json)
  end 
  
  def payment_requests_json
    result = assistant_payment_requests.map(&:as_ui_json)
    if can_add_request?
      result << AssistantPaymentRequest.empty_ui_json
    end
    result
  end
  
  def self.clients_page_json
    {
      methods: [:payment_requests_json],
      include: {
        user: { methods: [:assisting_display_name], only: [:id] }
      }
    }
  end
  
end