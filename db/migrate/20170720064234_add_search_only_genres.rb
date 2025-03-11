class AddSearchOnlyGenres < ActiveRecord::Migration[5.0]
  def change
    add_column :genres, :search_only, :integer, limit: 1, default: 0, null: false
    Genre.create(genre: 'Romance', category: 'Romance', search_only: true)
    Genre.create(genre: 'Sci Fi', category: 'Sci Fi', search_only: true)
    Genre.create(genre: 'Fantasy', category: 'Fantasy', search_only: true)
    add_index :genres, :category
  end
end
