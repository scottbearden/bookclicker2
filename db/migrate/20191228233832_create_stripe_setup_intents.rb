class CreateStripeSetupIntents < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_setup_intents do |t|
      t.references :user, foreign_key: true, null: false
      t.string :customer_id
      t.string :intent_id, null: false
      t.string :payment_method
      t.string :return_url
      t.string :status, null: false
      t.string :usage
      t.timestamps
      t.index [:intent_id], unique: true
    end
  end
end
