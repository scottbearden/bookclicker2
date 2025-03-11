class IndexBooksOnUserIdDeleted < ActiveRecord::Migration[5.0]
  def change
    add_index :books, [:user_id, :deleted]
  end
end
