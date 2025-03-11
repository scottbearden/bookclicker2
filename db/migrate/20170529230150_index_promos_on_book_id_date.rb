class IndexPromosOnBookIdDate < ActiveRecord::Migration[5.0]
  def change
    add_index :promos, [:book_id, :date]
  end
end
