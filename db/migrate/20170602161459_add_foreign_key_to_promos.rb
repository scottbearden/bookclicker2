class AddForeignKeyToPromos < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :promos, :books
  end
end
