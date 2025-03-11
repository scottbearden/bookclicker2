class CreateLists < ActiveRecord::Migration[5.0]
  def change
    create_table :lists do |t|
      
      t.integer :user_id, null: false
      t.string :platform_id, null: false
      t.string :platform, null: false
      t.integer :status, limit: 1, null: false, default: 1
      t.string :name
      t.integer :active_member_count
      t.decimal :open_rate, precision: 5, scale: 4
      t.decimal :click_rate, precision: 5, scale: 4
      
      t.integer :mention_price
      t.integer :feature_price
      t.integer :solo_price
      t.datetime :last_refreshed_at
      t.timestamps
      t.references :user, foreign_key: true
    end
  end
end