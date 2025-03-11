class CreateUsersxpenxname < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:users_pen_names)

    create_table :users_pen_names, id: false do |t|
      t.integer :user_id, null: false
      t.integer :pen_name_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
