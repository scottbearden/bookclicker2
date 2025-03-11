class CreateApixrequest < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:api_requests)

    create_table :api_requests, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.string :request_url
      t.integer :response_status
      t.text :response_data
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
