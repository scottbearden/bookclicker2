class Api::ListSubscriptionsController < Api::BaseController


  def update
    list_subscription = current_assistant_or_member_user.list_subscriptions.find_by_id(params[:id])
    if params[:subscribed].present?
      list_subscription.resubscribe
    else
      list_subscription.unsubscribe
    end
    render json: { 
      success: true, 
      list_subscription: list_subscription.as_json(ListSubscription.default_as_json)
    }
  end


end