class HandymanWechatsController < ApplicationController
  WECHAT_OPTIONS = {
    appid: ENV['HANDYMAN_WECHAT_APPID'],
    secret: ENV['HANDYMAN_WECHAT_SECRET'],
    token: ENV['HANDYMAN_WECHAT_TOKEN'],
    access_token: ENV['HANDYMAN_WECHAT_ACCESS_TOKEN'],
    jsapi_ticket: ENV['HANDYMAN_WECHAT_JSAPI_TICKET']
  }
  wechat_responder WECHAT_OPTIONS
end
