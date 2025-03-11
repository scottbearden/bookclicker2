class AddPenNameIdToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :pen_name_id, :integer, after: 'user_id'
    add_column :lists, :adopted_pen_name, :string, after: 'name' 
    List.active.each do |list|
      pen_name_id = list.user.try(:pen_names).try(:first).try(:id)
      list.update!(pen_name_id: pen_name_id)
    end
  end
end
