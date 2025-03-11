class CreateListSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :list_subscriptions do |t|
      t.integer :user_id, null: false
      t.integer :list_id, null: false
      t.integer :reservation_id
      t.string :email, null: false
      t.datetime :opt_out_at
      t.timestamps
      t.index [:user_id, :opt_out_at]
      t.index [:user_id, :list_id]
    end
  end
end
