class AddCategoryToGenre < ActiveRecord::Migration[5.0]
  def change
    add_column :genres, :category, :string
    Genre.where("genre like 'Romance%'").update_all(category: 'Romance')
    Genre.where("genre like 'Sci Fi%'").update_all(category: 'Sci Fi')
    Genre.where("genre like 'Fantasy%'").update_all(category: 'Fantasy')
    Genre.where(category: nil).each do |genre|
      genre.category = genre.genre
      genre.save!
    end
  end
end
