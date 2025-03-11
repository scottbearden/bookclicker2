class CreateCampaigns < ActiveRecord::Migration[5.0]
  def change
    create_table :campaigns do |t|
    	t.string :platform_id, null: false
    	t.integer :list_id, null: false
    	t.date :sent_on, null: false
    	t.string :status
    	t.integer :emails_sent, null: false
    	t.decimal :open_rate, precision: 5, scale: 4
      t.decimal :click_rate, precision: 5, scale: 4
    	t.string :subject, null: false
    	t.integer :reservation_id
    	t.datetime :seller_confirmed_at
    	t.timestamps
    	t.index [:list_id, :sent_on]
    	t.index :reservation_id
    	t.index [:list_id, :platform_id], unique: true
    end
  end
end
