conf_file = File.join('config','redis.yml')
conf = YAML.load(File.read(conf_file))
options = conf[Rails.env.to_s]

Sidekiq.configure_server { |c| c.redis = options }
Sidekiq.configure_client { |c| c.redis = options }
