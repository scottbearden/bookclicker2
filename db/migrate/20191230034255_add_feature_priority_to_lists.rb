class AddFeaturePriorityToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :sponsored_tier, :integer
    add_index :lists, [:sponsored_tier, :last_action_at]
  end
end
