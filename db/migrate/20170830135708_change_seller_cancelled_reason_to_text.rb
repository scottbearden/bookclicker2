class ChangeSellerCancelledReasonToText < ActiveRecord::Migration[5.0]
  def change
    execute("alter table reservations change column seller_cancelled_reason seller_cancelled_reason text default null")
  end
end
