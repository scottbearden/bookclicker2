class CreateList < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:lists)

    create_table :lists, id: :serial, primary_key: :id do |t|
      t.references :user, type: :integer, foreign_key: { to_table: :users }
      t.integer :pen_name_id
      t.integer :api_key_id
      t.string :platform_id, null: false
      t.string :platform, null: false
      t.integer :status, null: false
      t.string :name
      t.string :adopted_pen_name
      t.integer :active_member_count
      t.decimal :open_rate
      t.decimal :click_rate
      t.date :cutoff_date
      t.integer :mention_price
      t.integer :mention_is_swap_only, null: false
      t.integer :feature_price
      t.integer :feature_is_swap_only, null: false
      t.integer :solo_price
      t.integer :solo_is_swap_only, null: false
      t.datetime :last_refreshed_at
      t.datetime :last_action_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :sponsored_tier
    end
  end
end
