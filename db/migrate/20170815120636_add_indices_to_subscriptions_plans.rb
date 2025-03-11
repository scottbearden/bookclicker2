class AddIndicesToSubscriptionsPlans < ActiveRecord::Migration[5.0]
  def change
    add_index :subscription_plans, [:amount]
    add_index :subscription_plans, [:stripe_plan_id]
  end
end