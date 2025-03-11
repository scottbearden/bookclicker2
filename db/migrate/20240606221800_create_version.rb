class CreateVersion < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:versions)

    create_table :versions, id: :serial, primary_key: :id do |t|
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.longtext :object
      t.datetime :created_at
    end
  end
end
