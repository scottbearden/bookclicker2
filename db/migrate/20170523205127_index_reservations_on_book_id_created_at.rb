class IndexReservationsOnBookIdCreatedAt < ActiveRecord::Migration[5.0]
  def change
    add_index :reservations, [:book_id, :created_at]
  end
end
