class AddBooksIndexOnCreatedAt < ActiveRecord::Migration[5.0]
  def change
    remove_index :external_reservations, column: :list_id
    add_index :books, [:user_id, :updated_at]
  end
end
