require 'connection_pool'

conf_file = File.join('config','redis.yml')
conf = YAML.load(File.read(conf_file))
environment = Rails.env.to_s
redis_conf = conf[environment]

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(redis_conf)
end
