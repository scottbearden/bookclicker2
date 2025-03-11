class CreateOnexdayxinventory < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:one_day_inventories)

    create_table :one_day_inventories, id: :serial, primary_key: :id do |t|
      t.references :list, type: :integer, foreign_key: { to_table: :lists }
      t.string :source, null: false
      t.integer :solo, null: false
      t.integer :feature, null: false
      t.integer :mention, null: false
      t.date :date, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
