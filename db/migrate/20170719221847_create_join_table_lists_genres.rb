class CreateJoinTableListsGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :lists_genres, :id => false do |t|
      t.integer :list_id, null: false
      t.integer :genre_id, null: false
      t.index [:list_id, :genre_id], unique: true
      t.index [:genre_id, :list_id], unique: true
    end
    List.where.not(genre_id: nil).each do |list|
      ListsGenre.create!(list_id: list.id, genre_id: list.genre_id)
    end
    remove_column :lists, :genre_id
  end
end
