class IndexPenNamesOnAuthorName < ActiveRecord::Migration[5.0]
  def change
    add_index :pen_names, [:author_name, :verified]
  end
end
