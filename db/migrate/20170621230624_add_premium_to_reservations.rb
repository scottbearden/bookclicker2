class AddPremiumToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :premium, :integer, after: 'price'
  end
end
