class ConnectRefund < ApplicationRecord
  
  belongs_to :connect_payment, foreign_key: :charge_id, primary_key: :charge_id


  after_create :notify_buyer


  def notify_buyer
    HandleRefundJob.delay.perform(connect_payment.reservation_id)
  end
  
end
