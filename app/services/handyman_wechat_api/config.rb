require 'active_support/configurable'

module HandymanWechatApi
  class Config
    include ActiveSupport::Configurable
    config_accessor :appid, :secret, :access_token, :jsapi_ticket, :timeout

    def initialize
      config_file = File.join('config','handyman_wechat.yml')
      data = YAML.load(File.read(config_file))[Rails.env]
      config.appid = data['appid']
      config.secret = data['secret']
      config.access_token = data['access_token']
      config.jsapi_ticket = data['jsapi_ticket']
      config.timeout = 20
    end
  end
end
