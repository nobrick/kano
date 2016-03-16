require 'active_support/configurable'

module SMS
  class Config
    include ActiveSupport::Configurable
    config_accessor :api_key, :templates

    def initialize
      config_file = File.join('config','sms.yml')
      data = YAML.load(File.read(config_file))['sms']
      config.api_key = data['api_key']
      config.templates = data['templates']
    end
  end
end
