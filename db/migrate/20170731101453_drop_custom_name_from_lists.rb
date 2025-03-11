class DropCustomNameFromLists < ActiveRecord::Migration[5.0]
  def change
    execute("create table aaa_lists__#{Time.now.to_s.delete("- +:")} as select * from lists")
    remove_column :lists, :custom_name
  end
end
