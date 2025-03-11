class AddReplyMessageToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :reply_message, :text, after: 'message'
  end
end
