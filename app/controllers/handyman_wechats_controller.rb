class HandymanWechatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  WECHAT_OPTIONS = {
    appid: ENV['HANDYMAN_WECHAT_APPID'],
    secret: ENV['HANDYMAN_WECHAT_SECRET'],
    token: ENV['HANDYMAN_WECHAT_TOKEN'],
    access_token: ENV['HANDYMAN_WECHAT_ACCESS_TOKEN'],
    jsapi_ticket: ENV['HANDYMAN_WECHAT_JSAPI_TICKET']
  }
  wechat_responder WECHAT_OPTIONS

  on :event, with: 'subscribe' do |request|
    request.reply.text '欢迎您关注大象管家'
  end
end
