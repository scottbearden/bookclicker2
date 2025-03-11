class AddUuidKeyToPromos < ActiveRecord::Migration[5.0]
  def change
    add_column :promos, :uuid, :string, after: 'id'
    Promo.all.each(&:save!)
    change_column_null :promos, :uuid, false
    add_index :promos, :uuid, :unique => true
  end
end
