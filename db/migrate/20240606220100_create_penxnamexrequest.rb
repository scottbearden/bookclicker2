class CreatePenxnamexrequest < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:pen_name_requests)

    create_table :pen_name_requests, id: :serial, primary_key: :id do |t|
      t.integer :requestor_id, null: false
      t.integer :pen_name_id, null: false
      t.datetime :owner_notified_at
      t.string :owner_decision
      t.datetime :owner_decided_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
