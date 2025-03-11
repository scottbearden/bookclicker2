class AddSwapOnlyBooleanToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :feature_is_swap_only, :integer, limit: 1, default: 0, null: false, after: 'feature_price'
    add_column :lists, :mention_is_swap_only, :integer, limit: 1, default: 0, null: false, after: 'mention_price'
    add_column :lists, :solo_is_swap_only, :integer, limit: 1, default: 0, null: false, after: 'solo_price'
  end
end
