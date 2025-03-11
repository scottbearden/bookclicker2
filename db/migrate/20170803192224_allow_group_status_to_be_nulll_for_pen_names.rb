class AllowGroupStatusToBeNulllForPenNames < ActiveRecord::Migration[5.0]
  def change
    change_column_null :pen_names, :group_status, true
    execute("update pen_names set group_status = null where group_status = 'proprietary'")
    PenName.all.each(&:save!)
  end
end
