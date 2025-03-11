class AddGenreIdToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :genre_id, :integer, after: 'user_id'
  end
end
