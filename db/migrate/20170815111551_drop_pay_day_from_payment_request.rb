class DropPayDayFromPaymentRequest < ActiveRecord::Migration[5.0]
  def change
    remove_column :assistant_payment_requests, :pay_day
  end
end
