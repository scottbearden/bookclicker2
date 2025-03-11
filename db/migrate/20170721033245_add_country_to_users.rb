class AddCountryToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :country, :string, after: 'last_name'
  end
end
