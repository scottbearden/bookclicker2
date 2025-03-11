class ConnectPayment < ApplicationRecord
  
  belongs_to :reservation
  belongs_to :stripe_payment_intent

  after_create :notify_seller_of_payment
  
  has_many :connect_refunds, foreign_key: :charge_id, primary_key: :charge_id

  validates :reservation, presence: true
  validates :stripe_payment_intent, presence: true, on: :create
  validates_uniqueness_of :charge_id
  
  def paid_on
    created_at.to_date.pretty
  end

  def update_from_stripe_charge!(stripe_charge_object)
    card = stripe_charge_object.payment_method_details.card
    update!(
      charge_id: stripe_charge_object["id"],
      amount: stripe_charge_object["amount"],
      currency: stripe_charge_object["currency"],
      application_fee: stripe_charge_object["application_fee"],
      application_fee_amount: stripe_charge_object["application_fee_amount"],
      application: stripe_charge_object["application"],
      destination_acct_id: reservation.seller_stripe_acct_id,
      paid: stripe_charge_object["paid"],
      card_id: card["id"] || stripe_charge_object["payment_method"],
      last4: card["last4"],
      funding: card["funding"],
      exp_month: card["exp_month"],
      exp_year: card["exp_year"]
    )
  end

  def notify_seller_of_payment
    reservation.seller_recipients.each do |recipient|
      mail = ReservationMailer.confirm_reservation_payment(reservation, recipient, self)
      mail.deliver
      Email.create({
        user_id: recipient.id,
        mailer: mail.meta_data.mailer_id,
        email_address: recipient.email
      })
    end
  end
  
end
