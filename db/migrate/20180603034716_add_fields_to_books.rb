class AddFieldsToBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :amazon_author, :string
    add_column :books, :review_count, :integer
    add_column :books, :avg_review, :decimal, precision: 2, scale: 1
    add_column :books, :pub_date, :date
    add_column :books, :book_rank, :integer
  end
end
