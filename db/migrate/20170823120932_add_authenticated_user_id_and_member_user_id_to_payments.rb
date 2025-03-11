class AddAuthenticatedUserIdAndMemberUserIdToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :connect_payments, :reservation_buyer_user_id, :integer, after: 'reservation_id'
    execute("
      UPDATE connect_payments cp 
      JOIN reservations r on cp.reservation_id = r.id
      JOIN books b on r.book_id = b.id
      SET cp.reservation_buyer_user_id = b.user_id
    ")
  end
end
