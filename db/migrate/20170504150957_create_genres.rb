class CreateGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :genres do |t|
      t.string :genre, null: false
      t.index :genre
    end
    Genre.create(genre: 'Comedy')
    Genre.create(genre: 'Drama')
    Genre.create(genre: 'Horror')
    Genre.create(genre: 'Self Help')
    Genre.create(genre: 'Action/Adventure')
    Genre.create(genre: 'Romance')
    Genre.create(genre: 'Satire')
    Genre.create(genre: 'Tragedy')
    Genre.create(genre: 'Fantasy')
    Genre.create(genre: 'Science Fiction')
  end
end
