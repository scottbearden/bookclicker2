class CreateConnectxrefund < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:connect_refunds)

    create_table :connect_refunds, id: :serial, primary_key: :id do |t|
      t.string :refund_id, null: false
      t.integer :amount, null: false
      t.string :balance_transaction
      t.string :charge_id, null: false
      t.string :currency
      t.text :metadata
      t.string :status
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
