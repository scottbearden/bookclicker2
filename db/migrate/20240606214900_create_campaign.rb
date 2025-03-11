class CreateCampaign < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:campaigns)

    create_table :campaigns, id: :serial, primary_key: :id do |t|
      t.string :platform_id, null: false
      t.integer :list_id, null: false
      t.date :sent_on, null: false
      t.datetime :sent_at
      t.string :status
      t.integer :emails_sent, null: false
      t.decimal :open_rate
      t.decimal :click_rate
      t.string :subject, null: false
      t.string :name
      t.string :preview_url
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
