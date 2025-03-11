class CreateUserEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :user_events do |t|
      t.integer :user_id, null: false
      t.string :event, null: false
      t.string :event_detail
      t.timestamps
    end
    add_column :promos, :created_at, :datetime
    add_column :promos, :updated_at, :datetime
  end
end
