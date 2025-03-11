class CreateInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :inventories do |t|
      t.integer :list_id, null: false
      t.string :inv_type, null: false
      t.integer :sunday, limit: 1, null: false, default: 0
      t.integer :monday, limit: 1, null: false, default: 0
      t.integer :tuesday, limit: 1, null: false, default: 0
      t.integer :wednesday, limit: 1, null: false, default: 0
      t.integer :thursday, limit: 1, null: false, default: 0
      t.integer :friday, limit: 1, null: false, default: 0
      t.integer :saturday, limit: 1, null: false, default: 0
      t.timestamps
      t.references :list, foreign_key: true
    end
  end
end
