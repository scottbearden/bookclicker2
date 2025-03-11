class IntegrationsController < ApplicationController
  
  before_filter :require_current_member_user
  before_filter :block_assistant
  
  def show
    @api_keys = current_member_user.api_keys.as_json(
      only: [:id, :updated_at, :platform],
      methods: [:key, :platform_nice]
    )
  end
  
end
