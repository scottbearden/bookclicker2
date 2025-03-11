class CreateListsxgenre < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:lists_genres)

    create_table :lists_genres, id: false do |t|
      t.integer :list_id, null: false
      t.integer :genre_id, null: false
      t.integer :primary, null: false
    end
  end
end
