class CreateEmail < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:emails)

    create_table :emails, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.string :email_address, null: false
      t.string :mailer, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
