class PasswordToken < ApplicationRecord
  
  belongs_to :user
  
  after_initialize :generate_random_token
  after_initialize :set_expiration
  
  validates_presence_of :token, :expires_at
  
  def generate_random_token
    self.token ||= SecureRandom::urlsafe_base64(16)
  end
  
  def set_expiration
    self.expires_at = 2.hours.from_now
  end
  
  def self.valid?(token)
    entity = self.find_by_token(token)
    if entity.present?
      if entity.expires_at < Time.now
        OpenStruct.new(valid: false, message: 'Your password token has expired')
      elsif entity.user.blank?
        OpenStruct.new(valid: false, message: 'System could not locate user')
      else
        OpenStruct.new(valid: true)
      end
    else
      OpenStruct.new(valid: false, message: 'This password token was not found')
    end
  end
  
  def expire!
    self.expires_at = Time.now
    self.save!
  end
  
end