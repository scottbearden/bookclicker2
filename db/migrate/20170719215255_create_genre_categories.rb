class CreateGenreCategories < ActiveRecord::Migration[5.0]
  def change
    new_genres = ['Romance - Bad Boy', 'Romance - Biker', 'Romance - Billionaire', 'Romance - Sports', 'Romance - Military', 'Romance - Small Town', 'Romance - Sweet', 'Romance - Clean', 'Romance - Historical', 'Romance - LGBTQ', 'Romance - Interracial', 'Romance - Paranormal', 'Romance - Shifter', 'Romance - Vampire', 'Romance - Alien', 'Romance - Sci Fi', 'Romance - Time Travel', 'Romance - Fantasy', 'Romance - Dark', 'Romance - BDSM', 'Romance - Erotica', 'Romance - New Adult', 'Romance - YA', 'Sci Fi - Post Apocalypse', 'Sci Fi - Dystopian', 'Sci Fi - Alien Invasion', 'Sci Fi - First Contact', 'Sci Fi - Space Opera', 'Sci Fi - Military', 'Sci Fi - Adventure', 'Sci Fi - Cyberpunk', 'Sci Fi - Alternative History', 'Sci Fi - Zombie', 'Sci Fi - Mystery', 'Sci Fi - Suspense', 'Sci Fi - Metaphysical', "Fantasy", "LitRPG", "Women's Fiction", "Chick Lit", "Comedy", "Humor", "Mystery", "Thriller", "Suspense", "Horror", "Historical", "YA", "Urban Fantasy", "Action/Adventure", "Paranormal", "Non Fiction",
     'Fantasy - Epic', 'Fantasy - Swords and Sorcery', 'Fantasy - Military', 'Fantasy - Young Adult', 'Fantasy - Urban', 'Fantasy - Paranormal']
    new_genres.each do |genre|
      Genre.where(genre: genre).first_or_create!
    end
    Genre.where(genre: 'Romance').update_all(genre: 'Romance - Contemporary')
    Genre.where.not(genre: new_genres).destroy_all
  end
end