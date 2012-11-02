require 'redis'
require 'redis/objects'

Redis.current = Redis.new(:host => Rails.configuration.redis_host, :port => Rails.configuration.redis_port)
