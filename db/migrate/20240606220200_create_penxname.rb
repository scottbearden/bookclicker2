class CreatePenxname < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:pen_names)

    create_table :pen_names, id: :serial, primary_key: :id do |t|
      t.integer :user_id, null: false
      t.string :group_status
      t.string :author_profile_url
      t.string :author_name, null: false
      t.string :author_image
      t.integer :verified, null: false
      t.integer :promo_service_only, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :deleted, null: false
    end
  end
end
