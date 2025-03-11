class IntegrationsController < ApplicationController
  
  before_action :require_current_member_user
  before_action :block_assistant
  
  def show
    @api_keys = current_member_user.api_keys.as_json(
      only: [:id, :updated_at, :platform],
      methods: [:key, :platform_nice]
    )
  end
  
end
