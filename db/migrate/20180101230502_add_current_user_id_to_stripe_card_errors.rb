class AddCurrentUserIdToStripeCardErrors < ActiveRecord::Migration[5.0]
  def change
    add_column :stripe_card_errors, :reservation_id, :integer, after: :id
  end
end
