class MigrateApiDataFromUsersToApiKeys < ActiveRecord::Migration[5.0]
  def change
    User.where.not(mailchimp_user_id: nil).each do |user|
      user.api_keys.create!(
        platform: 'mailchimp',
        api_dc: user.mailchimp_api_dc,
        account_id: user.mailchimp_user_id,
        token: user.mailchimp_access_token
      )
    end
    
    User.where.not(aweber_account_id: nil).each do |user|
      user.api_keys.create!(
        platform: 'aweber',
        account_id: user.aweber_account_id,
        token: user.aweber_token,
        secret: user.aweber_secret
      )
    end
  end
end
