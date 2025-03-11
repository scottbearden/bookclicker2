class CreateListxrating < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:list_ratings)

    create_table :list_ratings, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.integer :list_id, null: false
      t.integer :rating, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
