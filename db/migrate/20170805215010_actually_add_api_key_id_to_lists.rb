class ActuallyAddApiKeyIdToLists < ActiveRecord::Migration[5.0]
  def change
    User.all.each do |u|
      puts u.id
      MailingListsUpdatorJob.perform(u.id)
    end
  end
end
