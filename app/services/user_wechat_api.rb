module UserWechatApi
  include UserWechatApi::Templates

  def self.wechat
    @wechat ||= load_wechat
  end

  private

  def self.load_wechat(opts = {})
    config = Wechat.config
    access_token = opts[:access_token] || config.access_token
    appid = opts[:appid] || config.appid
    secret = opts[:secret] || config.secret
    timeout = opts[:timeout] || config.timeout || 20
    skip_ssl = opts[:skip_verify_ssl]
    jsapi = opts[:jsapi_ticket] || config.jsapi_ticket
    Wechat::Api.new(appid, secret, access_token, timeout, skip_ssl, jsapi)
  end
end
