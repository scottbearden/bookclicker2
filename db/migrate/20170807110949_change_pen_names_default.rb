class ChangePenNamesDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:pen_names, :group_status, nil)
    execute("update pen_names set group_status = null where group_status = 'proprietary' ")
  end
end
