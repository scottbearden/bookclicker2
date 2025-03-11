class AddFormatAndPriceToBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :format, :string, after: 'author'
    add_column :books, :price, :decimal, precision: 7, scale: 2, after: 'format'
  end
end
