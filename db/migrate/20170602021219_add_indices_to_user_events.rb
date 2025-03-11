class AddIndicesToUserEvents < ActiveRecord::Migration[5.0]
  def change
    add_index :user_events, [:user_id, :event, :event_detail]
  end
end
