class CreateUsersAssistants < ActiveRecord::Migration[5.0]
  def change
    create_table :users_assistants do |t|
      t.integer :user_id, null: false
      t.integer :assistant_id, null: false
      t.timestamps
      t.index [:user_id, :assistant_id], unique: true
      t.index [:assistant_id, :user_id], unique: true
    end
    execute("create table backup.aaa_users_20170812 as select * from users")
    User.assistant.where.not(assistant_for_user_id: nil).each do |a|
      UsersAssistant.where(user_id: a.assistant_for_user_id, assistant_id: a.id).first_or_create!
    end
  end
end
