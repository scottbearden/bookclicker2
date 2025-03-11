class CreateStripeCardErrors < ActiveRecord::Migration[5.0]
  def change
    create_table :stripe_card_errors do |t|
      t.string :token
      t.string :card
      t.string :charge
      t.string :message
      t.string :error_type
      t.string :error_code
      t.string :decline_code
      t.timestamps
    end
  end
end


