class CreateInventory < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:inventories)

    create_table :inventories, id: :serial, primary_key: :id do |t|
      t.references :list, type: :integer, foreign_key: { to_table: :lists }
      t.string :inv_type, null: false
      t.integer :sunday, null: false
      t.integer :monday, null: false
      t.integer :tuesday, null: false
      t.integer :wednesday, null: false
      t.integer :thursday, null: false
      t.integer :friday, null: false
      t.integer :saturday, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
