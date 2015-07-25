#! /usr/bin/env ruby
# scripts/sidekiq_pusher.rb
# bundle exec scripts/sidekiq_pusher.rb Warehouse::FtpPull

klass = ARGV[0]
require 'sidekiq'
require 'logger'

$stdout.sync = true
logger = Logger.new($stdout)

redis_domain = ENV['REDIS_HOST']
redis_port   = ENV['REDIS_PORT']
sidekiq_worker_db   = ENV['SIDEKIQ_WORKER_DB']
sidekiq_namespace = ENV['SIDEKIQ_NAMESPACE']

raise(ArgumentError,'invalid redis_domain') unless redis_domain
raise(ArgumentError, 'invalid redis_port') unless redis_port
raise(ArgumentError, 'invalid sidekiq_worker_db') unless sidekiq_worker_db
raise(ArgumentError, 'invalid sidekiq_namespace') unless sidekiq_namespace
raise(ArgumentError, 'invalid klass') unless klass

redis_url = "redis://#{redis_domain}:#{redis_port}/#{sidekiq_worker_db}"

logger.info "connected redis on #{redis_url}"
Sidekiq.configure_client do |config|
  # config.redis = { url: "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}/#{ENV["SIDEKIQ_WORKER_DB"]}", namespace: "chattingcat_sidekiq_#{Rails.env}" }
  config.redis = { url: redis_url, namespace: sidekiq_namespace }
end

# NOTE: the keys of the hash passed to `push` must be of type `String`
Sidekiq::Client.push('class' => klass, 'args' => [])
logger.info "sidekiq:push:#{klass}"