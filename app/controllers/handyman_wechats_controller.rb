class HandymanWechatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  WECHAT_OPTIONS = %i{ appid secret token access_token jsapi_ticket }
    .map {|m| [m, HandymanWechatApi.config.send(m)]}.to_h
  wechat_responder WECHAT_OPTIONS

  on :event, with: 'subscribe' do |request|
    request.reply.text '欢迎您关注大象管家'
  end
end
