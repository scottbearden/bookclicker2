class EnforcePenNameIdForBook < ActiveRecord::Migration[5.0]
  def change
    change_column :books, :pen_name_id, :integer, null: false
  end
end
