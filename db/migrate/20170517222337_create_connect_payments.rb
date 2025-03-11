class CreateConnectPayments < ActiveRecord::Migration[5.0]
  def change
    create_table :connect_payments do |t|
      t.integer :reservation_id, null: false
      t.string :charge_id, null: false
      t.string :destination_acct_id, null: false
      t.integer :amount
      t.string :currency
      t.integer :paid, limit: 1
      t.string :card_id
      t.string :last4
      t.string :funding
      t.integer :exp_month, limit: 2
      t.integer :exp_year, limit: 4
      t.timestamps
      t.index :reservation_id
    end
  end
end
