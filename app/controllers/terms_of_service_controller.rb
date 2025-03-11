class TermsOfServiceController < ApplicationController
  before_action :check_tos_accepted, except: [:new, :accept]
  helper_method :current_member_user, :current_assistant_user, :current_assistant_or_member_user

  def new
    @tos = TermsOfService.last || TermsOfService.create(content: "Default terms of service")
  end

  def accept
    current_assistant_or_member_user.update(accepted_tos_at: Time.current)
    head :ok
  end

  private

  def check_tos_accepted
    unless current_assistant_or_member_user&.accepted_tos_at && current_assistant_or_member_user.accepted_tos_at >= TermsOfService.last.created_at
      redirect_to new_terms_of_service_path
    end
  end
end
