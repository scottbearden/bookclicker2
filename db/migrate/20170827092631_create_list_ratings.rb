class CreateListRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :list_ratings do |t|
      t.integer :user_id, null: false
      t.integer :list_id, null: false
      t.integer :rating, limit: 2, null: false
      t.timestamps
      t.index [:user_id, :list_id], unique: true
    end
  end
end
