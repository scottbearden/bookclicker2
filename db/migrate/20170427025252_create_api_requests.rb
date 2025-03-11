class CreateApiRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :api_requests do |t|
      t.integer :user_id, null: false
      t.string :request_url
      t.integer :response_status
      t.text :response_data
      t.timestamps
    end
  end
end
