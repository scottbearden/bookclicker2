class CreateStripexrequiresxactionxevent < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_requires_action_events)

    create_table :stripe_requires_action_events, id: :serial, primary_key: :id do |t|
      t.integer :current_user_id
      t.string :stripe_object_id
      t.text :next_action
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
