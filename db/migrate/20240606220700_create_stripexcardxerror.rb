class CreateStripexcardxerror < ActiveRecord::Migration[7.1]
  def change
    return unless reverting? || !table_exists?(:stripe_card_errors)

    create_table :stripe_card_errors, id: :serial, primary_key: :id do |t|
      t.integer :reservation_id
      t.string :token
      t.string :card
      t.string :charge
      t.string :message
      t.string :error_type
      t.string :error_code
      t.string :decline_code
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
