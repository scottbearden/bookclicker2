require 'sidekiq'
require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{Figaro.env.redis_host}:6379",
    password: Figaro.env.redis_password,
    network_timeout: 5
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{Figaro.env.redis_host}:6379",
    password: Figaro.env.redis_password,
    network_timeout: 5
  }
end

Sidekiq.default_worker_options = {
  unique: :until_executing
}

Sidekiq::Extensions.enable_delay!

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [
    "d63606414783232c0f56d3ae22e10deb69a6a4e967a900c1aa8dc26396", "a882892d2850c859f5c527396c184a97d495f8533b3e9e1430c51deb6d"
  ]
end