class GetAssistantSubscriptionStatusesJob
  include Sidekiq::Worker
  
  def perform
    AssistantPaymentRequest.all.each do |payment_request|
      sleep(0.4)
      payment_request.get_subscription_status!
    end
  end
  
end