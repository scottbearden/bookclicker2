class CreateBook < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:books)

    create_table :books, id: :serial, primary_key: :id do |t|
      t.references :user, type: :integer, foreign_key: { to_table: :users }
      t.integer :pen_name_id, null: false
      t.string :title, null: false
      t.string :format
      t.decimal :price
      t.date :launch_date
      t.string :cover_image_url
      t.text :blurb
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :amazon_author
      t.integer :review_count
      t.decimal :avg_review
      t.date :pub_date
      t.integer :book_rank
      t.integer :deleted, null: false
    end
  end
end
