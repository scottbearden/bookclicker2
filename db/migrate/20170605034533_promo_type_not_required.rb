class PromoTypeNotRequired < ActiveRecord::Migration[5.0]
  def change
    change_column_null :promos, :promo_type, true
  end
end
