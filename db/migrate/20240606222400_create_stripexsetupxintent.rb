class CreateStripexsetupxintent < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_setup_intents)

    create_table :stripe_setup_intents, id: :serial, primary_key: :id do |t|
      t.references :user, null: false, type: :integer, foreign_key: { to_table: :users }
      t.string :customer_id
      t.string :intent_id, null: false
      t.string :payment_method
      t.string :return_url
      t.string :status, null: false
      t.string :usage
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
