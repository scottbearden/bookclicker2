class MakeBooksAndPenNamesDeletable < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :deleted, :boolean, null: false, default: false
    add_column :pen_names, :deleted, :boolean, null: false, default: false
  end
end
