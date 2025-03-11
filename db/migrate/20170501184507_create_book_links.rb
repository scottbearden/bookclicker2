class CreateBookLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :book_links do |t|
      t.integer :book_id, null: false
      t.string :website_name, null: false
      t.string :link_url, null: false
      t.string :link_caption 
      t.references :book, foreign_key: true
    end
  end
end
