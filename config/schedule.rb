set :output, {:standard => 'log/cron.log', :error => 'log/cron.log'}

every '41 10,12,14 * * *' do
  runner "RetrieveSellerEmailCampaignsJob.perform"
end

every '15 * * * *' do
  runner "ProcessListSubscriptionsJob.perform"
end

every '28 4 * * *' do
  runner "GetAssistantSubscriptionStatusesJob.perform"
end

every '0 5 * * *' do
  runner "MailingListsUpdatorJob.perform_for_all"
end

every '18 18 * * *' do
  runner "RemoveObsoleteListsJob.perform"
end

every '3 6 * * *' do
  runner "IssueRequestedRefundsJob.perform"
end

every "2,12,22,32,42,52 * * * *" do
  runner "MessageNotificationsJob.perform"
end

every "25 1 3 * *" do
  runner "ClearLogFiles.perform"
end
