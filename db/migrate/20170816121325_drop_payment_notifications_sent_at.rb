class DropPaymentNotificationsSentAt < ActiveRecord::Migration[5.0]
  def change
    remove_column :reservations, :payment_notifications_sent_at
  end
end
