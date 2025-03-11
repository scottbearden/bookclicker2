class AddCustomNameToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :custom_name, :string, after: 'name'
    List.all.each(&:save)
  end
end
