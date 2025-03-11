class AddApplicationToConnectPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :connect_payments, :application_fee, :string, after: 'currency'
    add_column :connect_payments, :application, :string, after: 'application_fee'
  end
end
