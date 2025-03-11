class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.integer :user_id, null: false
      t.string :title, null: false
      t.string :author
      t.string :cover_image_url
      t.text :blurb
      t.timestamps
      t.references :user, foreign_key: true
    end
  end
end
