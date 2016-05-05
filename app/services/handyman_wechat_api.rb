require_relative 'handyman_wechat_api/config'
module HandymanWechatApi
  include HandymanWechatApi::Templates

  def self.wechat
    @wechat ||= load_wechat
  end

  def self.config
    @config ||= Config.new
  end

  private

  def self.load_wechat(opts = {})
    access_token = opts[:access_token] || config.access_token
    appid = opts[:appid] || config.appid
    secret = opts[:secret] || config.secret
    timeout = opts[:timeout] || config.timeout || 20
    skip_ssl = opts[:skip_verify_ssl]
    jsapi = opts[:jsapi_ticket] || config.jsapi_ticket
    Wechat::Api.new(appid, secret, access_token, timeout, skip_ssl, jsapi)
  end
end
