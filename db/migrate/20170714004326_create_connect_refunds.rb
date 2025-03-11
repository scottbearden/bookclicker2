class CreateConnectRefunds < ActiveRecord::Migration[5.0]
  def change
    create_table :connect_refunds do |t|
      t.string :refund_id, null: false
      t.integer :amount, null: false
      t.string :balance_transaction
      t.string :charge_id, null: false
      t.string :currency
      t.text :metadata
      t.string :status
      t.timestamps
    end
    add_index :connect_refunds, :charge_id
  end
end