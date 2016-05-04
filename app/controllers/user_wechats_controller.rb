class UserWechatsController < ApplicationController
  wechat_responder

  on :event, with: 'subscribe' do |request|
    request.reply.text '欢迎您关注大象管家'
  end
end
