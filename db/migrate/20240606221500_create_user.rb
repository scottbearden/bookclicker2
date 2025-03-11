class CreateUser < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:users)

    create_table :users, id: :serial, primary_key: :id do |t|
      t.integer :role, null: false
      t.string :first_name
      t.string :last_name
      t.string :country
      t.string :email, null: false
      t.datetime :email_verified_at
      t.integer :bookings_subscribed, null: false
      t.integer :messages_subscribed
      t.integer :confirmations_subscribed, null: false
      t.integer :auto_subscribe_on_booking, null: false
      t.string :auto_subscribe_email
      t.string :password_digest, null: false
      t.string :session_token, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :closed_at
    end
  end
end
