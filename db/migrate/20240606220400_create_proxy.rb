class CreateProxy < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:proxies)

    create_table :proxies, id: :serial, primary_key: :id do |t|
      t.string :ip, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
