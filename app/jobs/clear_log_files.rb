class ClearLogFiles
  include Sidekiq::Worker

  def perform
    File.delete(Rails.root.join("log", "production.log"))
    File.delete(Rails.root.join("log", "sidekiq.log"))
    File.delete(Rails.root.join("log", "cron.log"))
  end

end
