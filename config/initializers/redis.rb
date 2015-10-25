require 'connection_pool'

conf_file = File.join('config','redis.yml')
conf = YAML.load(File.read(conf_file))
redis_conf = conf[Rails.env.to_s]

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(redis_conf)
end
MessageBus.redis_config = redis_conf
