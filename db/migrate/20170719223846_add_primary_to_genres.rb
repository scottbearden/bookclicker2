class AddPrimaryToGenres < ActiveRecord::Migration[5.0]
  def change
    add_column :lists_genres, :primary, :integer, limit: 1, null: false, default: 0
    add_index :lists_genres, [:list_id, :primary]
    ListsGenre.where("1=1").update_all(primary: 1)
  end
end
