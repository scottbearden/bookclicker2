class CreateUsersPenNames < ActiveRecord::Migration[5.0]
  def change
    add_column :pen_names, :group_status, :string, after: 'user_id', default: 'proprietary', null: false
    create_table :users_pen_names, :id => false do |t|
      t.integer :user_id, null: false
      t.integer :pen_name_id, null: false
      t.timestamps
      t.index [:user_id, :pen_name_id], unique: true
      t.index [:pen_name_id, :user_id], unique: true
    end
    PenName.all.each do |pen_name|
      UsersPenName.create!(user_id: pen_name.user_id, pen_name_id: pen_name.id)
    end
  end
end

