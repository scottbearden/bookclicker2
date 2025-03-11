class CreateBookxlink < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:book_links)

    create_table :book_links, id: :serial, primary_key: :id do |t|
      t.integer :book_id
      t.string :website_name, null: false
      t.string :link_url, null: false
      t.string :link_caption
    end
  end
end
