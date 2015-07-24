#! /usr/bin/env ruby
# scripts/sidekiq_pusher.rb
# bundle exec scripts/sidekiq_pusher.rb Warehouse::FtpPull
klass = ARGV[0]
require 'sidekiq'

redis_domain = ENV['REDIS_HOST']
redis_port   = ENV['REDIS_PORT']
sidekiq_worker_db   = ENV['SIDEKIQ_WORKER_DB']
sidekiq_namespace = ENV['SIDEKIQ_NAMESPACE']

raise 'invalid environment' unless redis_domain
raise 'invalid environment' unless redis_port
raise 'invalid environment' unless sidekiq_worker_db
raise 'invalid environment' unless sidekiq_namespace
raise 'invalid environment' unless klass

redis_url = "redis://#{redis_domain}:#{redis_port}/#{sidekiq_worker_db}"
Sidekiq.configure_client do |config|
  # config.redis = { url: "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/#{ENV["SIDEKIQ_WORKER_DB"]}", namespace: "chattingcat_sidekiq_#{Rails.env}" }
  config.redis = { url: redis_url, namespace: sidekiq_namespace }
end

# NOTE: the keys of the hash passed to `push` must be of type `String`
Sidekiq::Client.push('class' => klass, 'args' => [])
puts "sidekiq:push:#{klass}"