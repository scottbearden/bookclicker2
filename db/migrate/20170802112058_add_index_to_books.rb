class AddIndexToBooks < ActiveRecord::Migration[5.0]
  def change
    execute("DROP INDEX index_books_on_user_id ON books")
    add_index :books, [:user_id, :pen_name_id]
  end
end
