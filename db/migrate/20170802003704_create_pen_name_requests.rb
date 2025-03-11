class CreatePenNameRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :pen_name_requests do |t|
      t.integer :requestor_id, null: false
      t.integer :pen_name_id, null: false
      t.datetime :owner_notified_at
      t.string :owner_decision
      t.datetime :owner_decided_at
      t.timestamps
      t.index [:requestor_id, :pen_name_id]
    end
  end
end
