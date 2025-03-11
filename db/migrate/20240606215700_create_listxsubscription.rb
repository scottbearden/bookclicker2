class CreateListxsubscription < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:list_subscriptions)

    create_table :list_subscriptions, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.integer :list_id, null: false
      t.integer :reservation_id
      t.string :email, null: false
      t.datetime :opt_in_at
      t.datetime :opt_in_succeeded_at
      t.datetime :opt_in_failed_at
      t.string :opt_in_failed_message
      t.datetime :opt_out_at
      t.datetime :opt_out_succeeded_at
      t.datetime :opt_out_failed_at
      t.string :opt_out_failed_message
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
