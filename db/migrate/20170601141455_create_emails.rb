class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.integer :user_id, null: false
      t.string :email_address, null: false
      t.string :mailer, null: false
      t.timestamps
      t.index [:user_id, :mailer, :created_at]
      t.index [:user_id, :email_address, :mailer]
      t.index [:email_address, :mailer]
    end
  end
end
