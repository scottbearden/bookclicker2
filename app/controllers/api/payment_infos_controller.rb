class Api::PaymentInfosController < Api::BaseController
  
  before_filter :require_current_member_user
  before_filter :block_assistant, except: [:default_source]
  
  def destroy
    bc_customer = current_member_user.bc_customer
    return render_404 unless bc_customer.present?
    card = bc_customer.sources.find_by_id(params[:id])
    return render_404 unless card.present?
    begin
      Stripe::PaymentMethod.detach(card.card_id)
    rescue Stripe::InvalidRequestError, Stripe::PermissionError => e
      puts "STRIPE ERROR IN PaymentInfosController: \n\n#{e.message}\n\n\n\n"
    ensure
      card.set_deleted
      render json: {
        sources: bc_customer.sources.reload
      }, stastus: :ok
    end
  end
  
  def default_source
    bc_customer = current_member_user.bc_customer
    return render_404 unless bc_customer.present?
    return render json: {
      default_source: bc_customer.default_source,
      default_source_id: bc_customer.default_source.try(:id)
    }, status: :ok
  end
  
  def set_default_source
    bc_customer = current_member_user.bc_customer
    return render_404 unless bc_customer.present?
    stripe_customer = Stripe::Customer.retrieve(bc_customer.customer_id)
    source = bc_customer.sources.find_by(card_id: params[:card_id])
    return render json: {}, status: :bad_request unless source.present?
    bc_customer.set_default_source(source, stripe_customer)
    return render json: {
      default_source: bc_customer.default_source,
      default_source_id: bc_customer.default_source.try(:id)
    }, status: :ok
  end
    
end
