class BetterFieldsForPaymentRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :assistant_payment_requests, :accepted_at, :datetime, after: 'pay_day'
    add_column :assistant_payment_requests, :declined_at, :datetime, after: 'accepted_at'
    add_column :assistant_payment_requests, :agreement_cancelled_at, :datetime, after: 'declined_at'
    remove_column :assistant_payment_requests, :response
    remove_column :assistant_payment_requests, :response_at
  end
end
