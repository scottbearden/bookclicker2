class CreateGenre < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:genres)

    create_table :genres, id: :serial, primary_key: :id do |t|
      t.string :genre, null: false
      t.string :category
      t.integer :search_only, null: false
    end
  end
end
