class CreateProxies < ActiveRecord::Migration[5.0]
  def change
    create_table :proxies do |t|
      t.string :ip, null: false
      t.timestamps
    end
  end
end
