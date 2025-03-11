class AllowNullNamesForPromos < ActiveRecord::Migration[5.0]
  def change
    change_column_null :promos, :name, true
  end
end
