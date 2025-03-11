class CreateUserxevent < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:user_events)

    create_table :user_events, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.string :event, null: false
      t.string :event_detail
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
