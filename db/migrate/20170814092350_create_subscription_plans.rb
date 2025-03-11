class CreateSubscriptionPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.string :stripe_plan_id
      t.string :interval
      t.string :currency, null: false
      t.integer :amount, null: false
      t.timestamps
    end
  end
end
