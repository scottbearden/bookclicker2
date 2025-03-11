class CreateSubscriptionxplan < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:subscription_plans)

    create_table :subscription_plans, id: :serial, primary_key: :id do |t|
      t.string :name
      t.string :stripe_acct_id
      t.string :stripe_plan_id
      t.string :interval
      t.string :currency, null: false
      t.integer :amount, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
