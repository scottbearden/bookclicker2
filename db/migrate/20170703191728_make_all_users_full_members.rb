class MakeAllUsersFullMembers < ActiveRecord::Migration[5.0]
  def change
    User.all.each do |user|
      user.role = 'full_member'
      user.save!
    end
    User.all.each do |user|
      MailingListsUpdatorJob.perform(user.id)
    end
  end
end
