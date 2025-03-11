class CreatePenNames < ActiveRecord::Migration[5.0]
  def change
    create_table :pen_names do |t|
      t.integer :user_id, null: false
      t.string :author_profile_url
      t.string :author_name, null: false
      t.string :author_image
      t.integer :verified, limit: 1, default: 0, null: false
      t.integer :promo_service_only, limit: 1, default: 0, null: false
      t.timestamps
      
      t.index  [:user_id, :promo_service_only]
    end
  end
end
#remove author from books
#add pen_name_id to books

# add pen_name_id to lists
