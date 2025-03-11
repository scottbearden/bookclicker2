class AddPreviewUrlAndNameToCampaigns < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :name, :string, after: 'subject'
    add_column :campaigns, :preview_url, :string, after: 'name'
  end
end
