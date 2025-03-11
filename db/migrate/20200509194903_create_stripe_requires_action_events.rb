class CreateStripeRequiresActionEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_requires_action_events do |t|
      t.integer :current_user_id
      t.string :stripe_object_id
      t.text :next_action
      t.timestamps
    end
  end
end
