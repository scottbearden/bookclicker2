class ChangeListsDefaultStatus < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:lists, :status, 0)
    execute("
      update lists l join users u on l.user_id = u.id
      set l.status = 0 where u.role not in (2,3)")
  end
end
