class CreatePromos < ActiveRecord::Migration[5.0]
  def change
    create_table :promos do |t|
      t.integer :book_id, null: false
      t.string :name, null: false
      t.integer :list_size, null: false
      t.date :date, null: false
      t.string :promo_type, null: false
      t.index :book_id
    end
  end
end
