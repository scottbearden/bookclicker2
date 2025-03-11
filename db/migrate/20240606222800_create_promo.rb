class CreatePromo < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:promos)

    create_table :promos, id: :serial, primary_key: :id do |t|
      t.string :uuid, null: false
      t.references :book, null: false, type: :integer, foreign_key: { to_table: :books }
      t.string :name
      t.integer :list_size, null: false
      t.date :date, null: false
      t.string :promo_type
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
