class CreateExternalxreservation < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:external_reservations)

    create_table :external_reservations, id: :serial, primary_key: :id do |t|
      t.integer :list_id, null: false
      t.string :recorded_list_name
      t.date :date, null: false
      t.string :book_owner_name
      t.string :book_owner_email
      t.string :book_title
      t.string :book_link
      t.string :inv_type, null: false
      t.datetime :campaigns_fetched_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
