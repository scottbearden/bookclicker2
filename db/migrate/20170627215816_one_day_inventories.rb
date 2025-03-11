class OneDayInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :one_day_inventories do |t|
      t.integer :list_id, null: false
      t.integer :solo, null: false, limit: 2, default: 0
      t.integer :feature, null: false, limit: 2, default: 0
      t.integer :mention, null: false, limit: 2, default: 0
      t.date :date, null: false
      t.timestamps
      t.index [:list_id, :date], unique: true
      t.references :list, foreign_key: true
    end
  end
end
